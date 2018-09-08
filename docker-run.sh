#!/bin/bash

# This script is used in Docker containers. It is not supposed to be run outside a
# Docker container.

# Set PHP timezone
echo "Time zone: ${DATE_TIMEZONE}"
echo "date.timezone=${DATE_TIMEZONE}" > /usr/local/etc/php/conf.d/mlinvoice.ini

if [ ! -d "$MYSQL_BASEDIR/data" ]; then
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        echo >&2 'error: database is uninitialized and root password is not specified '
        exit 1
    fi

    mkdir -p "$MYSQL_BASEDIR"

    echo 'Initializing database'
    mysql_install_db --datadir="$MYSQL_BASEDIR/data"

    # Run MariaDB
    echo 'Starting MariaDB'
    /usr/bin/mysqld_safe --datadir="$MYSQL_BASEDIR/data" --timezone=${DATE_TIMEZONE} &
    pid="$!"
    echo "Started MariaDB $pid"

    mysql=( mysql -uroot )

    for i in {30..0}; do
        if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'MariaDB is starting up...'
        sleep 1
    done
    if [ "$i" = 0 ]; then
        echo >&2 'Could not establish connection to MariaDB'
        exit 1
    fi

    echo 'Setting up privileges'
    "${mysql[@]}" <<-EOSQL
        SET @@SESSION.SQL_LOG_BIN=0;
        DELETE FROM mysql.user WHERE user NOT IN ('mysql.sys', 'mysqlxsys', 'root') OR host NOT IN ('localhost') ;
        SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${MYSQL_ROOT_PASSWORD}');
        GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
        DROP DATABASE IF EXISTS test;
        FLUSH PRIVILEGES;
EOSQL

    mysql+=( -p"${MYSQL_ROOT_PASSWORD}" )

    echo "Creating database $MYSQL_DATABASE"
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" | "${mysql[@]}"
    mysql+=( "$MYSQL_DATABASE" )

    if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" | "${mysql[@]}"

        if [ "$MYSQL_DATABASE" ]; then
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" | "${mysql[@]}"
        fi
    fi

    echo "Stopping MariaDB $pid"
    if ! kill -s TERM `cat /var/run/mysqld/mysqld.pid` || ! wait "$pid"; then
        echo >&2 'MariaDB init failed.'
        exit 1
    fi

    echo
    echo 'MariaDB initial setup complete'
    echo
fi

if [ ! -f /usr/local/mlinvoice/README.md ]; then
    cd /tmp
    echo "Checking MLInvoice version information"
    ZIP=`curl -s https://www.labs.fi/mlinvoice_version.php | grep package | sed -e 's/.*\(http.*\)".*/\1/'`
    rm -rf *.zip
    echo "Downloading $ZIP"
    curl $ZIP > mlinvoice.zip
    cd /usr/local
    unzip -o /tmp/mlinvoice.zip
    cd mlinvoice

    chown -R www-data:www-data /usr/local/mlinvoice
    rm -rf /usr/local/mlinvoice/config.php
    sed -i -r "s/define\('_DB_SERVER_', '.*?'\);/define('_DB_SERVER_', '127.0.0.1');/" /usr/local/mlinvoice/config.php.sample
    sed -i -r "s/define\('_DB_USERNAME_', '.*?'\);/define('_DB_USERNAME_', '$MYSQL_USER');/" /usr/local/mlinvoice/config.php.sample
    sed -i -r "s/define\('_DB_PASSWORD_', '.*?'\);/define('_DB_PASSWORD_', '$MYSQL_PASSWORD');/" /usr/local/mlinvoice/config.php.sample
fi

# Run MariaDB
/usr/bin/mysqld_safe --datadir="$MYSQL_BASEDIR/data" --timezone=${DATE_TIMEZONE} &

# Run Apache
echo "Running Apache. Ready for connections."
if [ "x$LOG_LEVEL" == 'xdebug' ]; then
    /usr/sbin/apachectl -DFOREGROUND -k start -e debug
else
    &>/dev/null /usr/sbin/apachectl -DFOREGROUND -k start
fi
