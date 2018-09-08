MLInvoice Vagrant
=================

This repository provides an [MLInvoice](https://github.com/emaijala/MLinvoice) setup in Docker container. It can be used to easily install MLInvoice for testing or further use on any computer that supports Docker.

All applications apart from the prerequisites are installed in the virtual machine, which means the actual machine including its operating system settings and applications is kept intact.

*N.B.* MLInvoice's database is stored in Docker volume /var/lib/mysql. Make sure to not delete it to keep your data intact.

Prerequisites
-------------

- Enough disk space for the Docker container. Maybe ~1 gigabyte.
- Internet connection so thatthe required files can be downloaded. A fast connection helps for a fast installation.
- [Docker](https://www.docker.com/)
- Basic command prompt (terminal) usage

Installation
------------

1. Install the prerequisites.
2. Download this repository as a zip file: https://github.com/emaijala/MLInvoice-Docker/archive/master.zip
3. Unpack the zip file somewhere. Note that you need to find it in the command line. The following steps assume it's a Windows machine and the location is C:\MLInvoice.
4. Open Command Prompt: In Windows, bring up the Start menu and enter "command" ("komento" in Finnish) to search for it. Click when found.
5. Navigate to the forementioned directory by typing the following commands:

       c:
       cd \MLInvoice

6. Create the Docker image:

       docker build -t mlinvoice .

7. Docker will now create an image. This may take a good while depending on the speed of the internet connection and the computer.
8. Create and run a container:

        docker run -it -p 8000:80 mlinvoice

9. On the first run, the above will create the database and install MLInvoice. When the installation is completed, navigate to http://localhost:8000/ to start using MLInvoice.
10. If you want to stop the container, run the following command:

        docker stop <container>

    Where <container> is the container ID.

11. To start the container again, run the following command:

        docker start <container>

12. If you want to get rid of MLInvoice, destroy the container:

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
