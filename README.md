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
    * The required Oracle Database installation files from [OTN](https://www.oracle.com/technetwork/database/) (supports versions up to 21.3.0 including Express Edition, as of September 22, 2021). **Note:** For [Oracle Database 21c XE](https://oracle.com/xe), you are no longer required to download the binaries (see issue #39).
    * [Oracle Application Express](https://apex.oracle.com/download) (supports versions up 22.2 as of January 01, 2023)
    * [Oracle REST Data Services](https://www.oracle.com/technetwork/developer-tools/rest-data-services/downloads/index.html) (supports versions up to 23.1 as of April 01, 2023)
1. For releases after [0.6.0](https://github.com/fuzziebrain/docker-apex-stack/releases/tag/0.6.0), either choose to use the binaries from [OpenJDK](https://openjdk.java.net/), download a licensed Java runtime, or the [free to use](https://blogs.oracle.com/java/post/free-java-license) Java 17 from Oracle. Please refer to the additonal notes section [below](#Additional-Notes-About-the-Settings-File) for details about the `INSTALL_FILE_JAVA` parameter.
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

## Quick Start

[Martin](https://github.com/martindsouza) [suggested](https://twitter.com/martindsouza/status/1412799632053211141), so here it is! Now included is the the [`quickstart.sh`](./quickstart.sh) script. Simply:
1. Execute the script.
1. Enter your email address for the APEX instance administrator.
1. Optionally, enter a preferred container name.
1. If all's good, note down your container name and password.
1. Enter `Y` to continue.
1. Wait till there is minimal or no activity in the script then go to http://localhost:8080/ords/apex.

If you are new to APEX, then I highly recommend checking out some of the learning resources [here](https://apex.oracle.com/en/learn/).

```
$ ./quickstart.sh
Enter an email address for your APEX administrator (required): apexdev@example.com
Container name (leave empty to have one generated for you): apexiscool
##### Important Information #####
Your Docker container name is: apexiscool
Your password for the database and APEX internal workspace is: donotcommit

We are now ready to build the Docker image and deploy your container.
Type "Y" to continue or CTRL-C to exit: y
```

> **Note**
>
> Should you forget to save your password, you can find it in the generated settings file along with any other details about the container. It is named after your container, e.g. `apexiscool.env`.

## Additional Notes About the Settings File

* Specify the Docker network to attach to using the parameter `DOCKER_NETWORK_NAME`. The run script will check if the network exists, and if not, create it.
* The parameter `RTU_ENABLED` has been introduced. **It is experimental and may not work**. It allows users to create containers that can be used to create an image from using Docker [commit](https://docs.docker.com/engine/reference/commandline/commit/). Set the value to "Y" if this ability is required.
* Use the `FILES_DIR` parameter to specify the local path to all the required installation files, e.g. `/path/to/my/downloads`.
* Set the value of `ALLOW_DB_PATCHING` to `Y` to preserve files needed to successfully patch the database software with *OPatch*.
* [As of December 5, 2019](https://blogs.oracle.com/database/machine-learning%2c-spatial-and-graph-no-license-required-v2), Oracle Machine Learning (previously known as Oracle Advanced Analytics) option is now included with all editions of Oracle Database 12c R2 and later, including 18c Express Edition (XE). Use the `OML4R_SUPPORT` parameter to install database support for running embedded R scripts. At the moment, this option is only valid for 18c or later.
* SQL Developer Web is now availablel with ORDS version 19.4. This feature is enabled by default. To turn it off, set the environment variable `SQLDEVWEB` to `N`. The REST-enabled SQL feature can be managed by the variable `REST_ENABLED_SQL`, but note that this value is ignored if SQL Developer Web is activated. For builds with earlier ORDS versions, the added configuration properties are safely ignored.
* `DATABASEAPI` parameter added to enable Database API support for ORDS 19.x and later.
* The variable `INSTALL_FILE_JAVA` accepts the following values:
    * `java17` (default)
    * `openjdk11`
    * The filename of Java runtime tarball that you can download from [here](https://www.oracle.com/technetwork/java/javase/downloads/).
* Using the sample settings, the following are accessible:
    | Port | Application | URL |
    |-|-|-|
    | 8080 | APEX | http://localhost:8080 |
    | 1521 | Database | N/A |
