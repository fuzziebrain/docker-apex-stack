#!/bin/bash

ENV_FILE=${1:-.env}

. $ENV_FILE

BASE_DIR=$(pwd -P)
DB_VERSION=${DB_VERSION:-18.4.0}
DB_EDITION=$(echo ${DB_EDITION:-xe} | tr '[:upper:]' '[:lower:]')

case "$DB_EDITION" in
  "ee")
    DB_EDITION_FLAG=-e
    ;;
  "se2")
    DB_EDITION_FLAG=-s
    ;;
  *)
    DB_EDITION_FLAG=-x
    ;;
esac

if [ -d 'dockerfiles' ]; then
  rm -rf dockerfiles;
fi

echo "##### Grabbing official Docker images from Oracle #####"
git clone https://github.com/oracle/docker-images.git tmp

mv tmp/OracleDatabase/SingleInstance/dockerfiles/ .

rm -rf tmp/

echo "##### Staging RPM #####"
if [ $DB_VERSION = '19.3.0' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/LINUX.X64_193000_db_home.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '18.4.0' ] && [ $DB_EDITION = 'xe' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/oracle-database-xe-18c-1.0-1.x86_64.rpm
  DOCKER_FILE=Dockerfile.$DB_EDITION
elif [ $DB_VERSION = '18.3.0' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/LINUX.X64_180000_db_home.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '12.2.0.1' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/linuxx64_12201_database.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '12.1.0.2' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/linuxamd64_12102_database_1of2.zip
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$BASE_DIR/files/linuxamd64_12102_database_2of2.zip
  DOCKER_FILE=Dockerfile.$DB_EDITION
else
  echo "Unknown or unsupported database version and/or edition."
fi

cd $BASE_DIR

# RTU_ENABLED default 'N'
# The following is used for preparing "ready to use" images for internal use only.
if [[ $RTU_ENABLED =~ $(Y|y) ]]; then
  echo "##### Modify target Dockerfile #####"
  REPLACEMENT_STRING="COPY scripts/setup/ \$ORACLE_BASE/scripts/setup/\nCOPY scripts/startup/ \$ORACLE_BASE/scripts/startup/\nCOPY files/ /tmp/files/\n"
  sed -i -r "s|^VOLUME.+$|${REPLACEMENT_STRING}|g" dockerfiles/${DB_VERSION}/${DOCKER_FILE:-Dockerfile}
  mkdir -p dockerfiles/${DB_VERSION}/files
  cp files/$INSTALL_FILE_APEX files/$INSTALL_FILE_ORDS files/$INSTALL_FILE_JAVA dockerfiles/${DB_VERSION}/files/
  cp -R scripts dockerfiles/${DB_VERSION}/scripts
fi

echo "##### Building Docker Image for Oracle Database ${DB_VERSION} ${DB_EDITION} #####"
cd dockerfiles && . buildDockerImage.sh -v ${DB_VERSION} ${DB_EDITION_FLAG}

cd $BASE_DIR
echo "##### Done #####"
