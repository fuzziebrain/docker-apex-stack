# Build an APEX Stack with Docker

> For background information on this repository, please read this [blog post](https://fuzziebrain.com/content/id/1902/).

## Prerequisites

* Installed the following:
    * Git
    * Curl
    * Docker (of course)

> IMPORTANT
>
> Build and execution has been tested in Linux only. It should work in Mac OS, but likely not with Windows. Sorry.

## Getting Started

1. Git clone this repository and set it as the working directory.
2. Download the installer files:
    * [Oracle Database 18c XE](https://oracle.com/xe) or any of the required installation files from [OTN](https://www.oracle.com/technetwork/database/) (supports versions up to 19.3 as of April 25, 2019)
    * [Oracle Application Express](https://apex.oracle.com/download) (supports versions up 21.1 as of May 12, 2021)
    * [Oracle REST Data Services](https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html) (supports versions up to 20.4.3 as of May 12, 2021)
    * [Java Development Kit SE 8](https://www.oracle.com/technetwork/java/javase/downloads/) (**IMPORTANT**: Please download the tarball, e.g. `jdk-8u291-linux-x64.tar.gz`.)
3. Place all four files in the sub-directory `files`.
4. Create a new file that contains the required variables. Make a copy of `settings.env.sample`, e.g. `mysettings.env`, and modify as desired. The file should contain the following variables:
    ```bash
    ORACLE_SID=XE
    ORACLE_PDB=XEPDB1
    ORACLE_PWD=Oracle18
    APEX_ADMIN_EMAIL=myemail@domain.com
    APEX_ADMIN_PWD=Oracle__18
    APEX_PUBLIC_USER_PWD=Oracle18_1
    APEX_LISTENER_PWD=Oracle18_2
    APEX_REST_PUBLIC_USER_PWD=Oracle18_3
    ORDS_PUBLIC_USER_PWD=Oracle18_4
	INSTALL_FILE_APEX=apex_21.1.zip
	INSTALL_FILE_ORDS=ords-20.4.3.050.1904.zip
	INSTALL_FILE_JAVA=jdk-8u291-linux-x64.tar.gz
    DOCKER_ORDS_PORT=50080
    DOCKER_EM_PORT=55500
    DOCKER_DB_PORT=51521
    DB_VERSION=18.4.0
    DB_EDITION=xe
    DOCKER_NETWORK_NAME=das_network
    ALLOW_DB_PATCHING=N
    OML4R_SUPPORT=N
    REST_ENABLED_SQL=Y
    RTU_ENABLED=N
    SQLDEVWEB=Y
    DATABASEAPI=Y
    ```

    > * Specify the Docker network to attach to using the parameter `DOCKER_NETWORK_NAME`. The run script will check if the network exists, and if not, create it.
    > * The parameter `RTU_ENABLED` has been introduced. It allows users to create containers that can be used to create an image from using Docker [commit](https://docs.docker.com/engine/reference/commandline/commit/). Set the value to "Y" if this ability is required.
    > * Use the `FILES_DIR` parameter to specify the local path to all the required installation files, e.g. `/path/to/my/downloads`.
    > * Set the value of `ALLOW_DB_PATCHING` to `Y` to preserve files needed to successfully patch the database software with *OPatch*.
    > * [As of December 5, 2019](https://blogs.oracle.com/database/machine-learning%2c-spatial-and-graph-no-license-required-v2), Oracle Machine Learning (previously known as Oracle Advanced Analytics) option is now included with all editions of Oracle Database 12c R2 and later, including 18c Express Edition (XE). Use the `OML4R_SUPPORT` parameter to install database support for running embedded R scripts. At the moment, this option is only valid for 18c or later.
    > * SQL Developer Web is now availablel with ORDS version 19.4. This feature is enabled by default. To turn it off, set the environment variable `SQLDEVWEB` to `N`. The REST-enabled SQL feature can be managed by the variable `REST_ENABLED_SQL`, but note that this value is ignored if SQL Developer Web is activated. For builds with earlier ORDS versions, the added configuration properties are safely ignored.
    > * **New** `DATABASEAPI` parameter added to enable Database API support for ORDS 19.x and later.
5. Run the first script to grab the latest Docker [images](https://github.com/oracle/docker-images) from Oracle and build the Oracle Database image. The script takes one parameter, the environment filename (`mysettings.env`):
    ```bash
    $ bash 01-build.sh mysettings.env
    ```
6. Run the final script to create and run the container, where the container name is `das`:
    ```bash
    $ bash 02-run.sh das mysettings.env
    ```

Using the sample settings, the following are accessible:

| Port | Application | URL |
|-|-|-|
| 50080 | APEX | http://localhost:50080 |
| 51521 | Database | N/A |
| 55500 | Enterprise Manager Express | https://localhost:55500/em |
