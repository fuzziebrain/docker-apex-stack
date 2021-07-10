# Build an APEX Stack with Docker

> For background information on this repository, please read this [blog post](https://fuzziebrain.com/content/id/1902/).

## Prerequisites

* Installed the following:
    * Git
    * Curl
    * Docker (of course)

> IMPORTANT
>
> Build and execution has been tested in Linux only. It should work in Mac OS and Windows with Windows Subsystem for Linux 2.

## Getting Started

1. Git clone this repository and set it as the working directory.
1. Download the installer files:
    * [Oracle Database 18c XE](https://oracle.com/xe) or any of the required installation files from [OTN](https://www.oracle.com/technetwork/database/) (supports versions up to 19.3 as of April 25, 2019)
    * [Oracle Application Express](https://apex.oracle.com/download) (supports versions up 21.1 as of May 12, 2021)
    * [Oracle REST Data Services](https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html) (supports versions up to 21.2.0.174.1826 as of July 10, 2021)
1. For releases after [0.6.0](https://github.com/fuzziebrain/docker-apex-stack/releases/tag/0.6.0), either choose to use the binaries from [OpenJDK](openjdk.java.net/) or download a licensed Java runtime from Oracle. Please refer to the additonal notes section below for details about the `INSTALL_FILE_JAVA` parameter.
1. Place all installer files in the sub-directory `files`.
1. Create a file that contains the required environment variables for your build. Please refer to the additonal notes [below](#Additional-Notes-About-the-Settings-File) for more information about the various parameters that can be set. Included in this repository are two examples or templates that you can use:
    * [`settings.env.sample`](./settings.env.sample).
    * [`settings_db19c.env.sample`](./settings_db19c.env.sample).
1. Run the first script to grab the latest Docker [images](https://github.com/oracle/docker-images) from Oracle and build the Oracle Database image. The script takes one parameter, the environment filename (`mysettings.env`):
    ```bash
    $ bash 01-build.sh mysettings.env
    ```
1. Run the final script to create and run the container, where the container name is `das`:
    ```bash
    $ bash 02-run.sh das mysettings.env
    ```

## Additional Notes About the Settings File

* Specify the Docker network to attach to using the parameter `DOCKER_NETWORK_NAME`. The run script will check if the network exists, and if not, create it.
* The parameter `RTU_ENABLED` has been introduced. **It is experimental and may not work**. It allows users to create containers that can be used to create an image from using Docker [commit](https://docs.docker.com/engine/reference/commandline/commit/). Set the value to "Y" if this ability is required.
* Use the `FILES_DIR` parameter to specify the local path to all the required installation files, e.g. `/path/to/my/downloads`.
* Set the value of `ALLOW_DB_PATCHING` to `Y` to preserve files needed to successfully patch the database software with *OPatch*.
* [As of December 5, 2019](https://blogs.oracle.com/database/machine-learning%2c-spatial-and-graph-no-license-required-v2), Oracle Machine Learning (previously known as Oracle Advanced Analytics) option is now included with all editions of Oracle Database 12c R2 and later, including 18c Express Edition (XE). Use the `OML4R_SUPPORT` parameter to install database support for running embedded R scripts. At the moment, this option is only valid for 18c or later.
* SQL Developer Web is now availablel with ORDS version 19.4. This feature is enabled by default. To turn it off, set the environment variable `SQLDEVWEB` to `N`. The REST-enabled SQL feature can be managed by the variable `REST_ENABLED_SQL`, but note that this value is ignored if SQL Developer Web is activated. For builds with earlier ORDS versions, the added configuration properties are safely ignored.
* `DATABASEAPI` parameter added to enable Database API support for ORDS 19.x and later.
* The variable `INSTALL_FILE_JAVA` accepts the following values:
    * `openjdk1.8`
    * `openjdk11`
    * The filename of Java runtime tarball that you can download from [here](https://www.oracle.com/technetwork/java/javase/downloads/). It is recommended that you download the latest Java 8 server JRE, e.g. `server-jre-8u291-linux-x64.tar.gz`.
* Using the sample settings, the following are accessible:
    | Port | Application | URL |
    |-|-|-|
    | 50080 | APEX | http://localhost:50080 |
    | 51521 | Database | N/A |
    | 55500 | Enterprise Manager Express | https://localhost:55500/em |
