MLInvoice
=========

This repository provides an [MLInvoice](https://github.com/emaijala/MLinvoice) setup in Docker container.

*N.B.* MLInvoice's database is stored in Docker volume /var/lib/mysql. Make sure to not delete it to keep your data intact.


Installation
------------

1. Download the image:

        docker pull emaijala/mlinvoice

2. Create and run a container:

        docker run -it -p 8000:80 mlinvoice

3. On the first run, the above will create the database and install MLInvoice. When the installation is completed, navigate to http://localhost:8000/ to start using MLInvoice.

4. If you want to stop the container, run the following command:

        docker stop <container>

    Where <container> is the container ID.

5. To start the container again, run the following command:

        docker start <container>

6. If you want to get rid of MLInvoice, destroy the container (THIS WILL DESTROY everything including MLInvoice's database):

        docker rm <container>

    Also destroy the relevant image:

        docker images
        docker rmi <image>

13. Other useful commands:

    List all containers and their status:

        docker ps -a

    List all images:

        docker images

Configuration
-------------

While the container comes ready to go, you may need to configure some of the MLInvoice settings found in config.php file. This is especially for making sending email work properly. After the installation is complete and the container is running, you can open a terminal connection to it with the following command:

    docker exec -it <container> /bin/bash

Available editors are at least `nano` and `vi`.

See https://www.labs.fi/mlinvoice_installation.eng.php for more information about the configuration and https://www.labs.fi/mlinvoice_usage.eng.php for information on how to get started.
