#!/usr/bin/env bash

ENV_FILE=${1:-.env}

. $ENV_FILE

BASE_DIR=$(pwd -P)
DB_VERSION=${DB_VERSION:-18.4.0}
DB_EDITION=$(echo ${DB_EDITION:-xe} | tr '[:upper:]' '[:lower:]')
FILES_DIR=${FILES_DIR:-$BASE_DIR/files}
ALLOW_DB_PATCHING=${ALLOW_DB_PATCHING:-N}
OML4R_SUPPORT=${OML4R_SUPPORT:-N}
XE_DOWNLOAD_BASE_URL="https://download.oracle.com/otn-pub/otn_software/db-express/"

SED_OPTS='-i -r'
if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_OPTS='-i .bak -E'
fi

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

function setupR() {
  echo "Installing R for Oracle ML Support"
  # Copy the installR.sh to the base Docker directory.
  cp -R $BASE_DIR/oml-kit/installR.sh .

  # Modify the COPY statement.
  sed $SED_OPTS "s|^(COPY)(.+CHECK_SPACE_FILE.+INSTALL_DIR/)$|\1 installR.sh\2|g" ${DOCKER_FILE:-Dockerfile}

  REPLACEMENT_STRING=$'\$INSTALL_DIR/installR.sh \&\& \\\ \\\n    '
  sed $SED_OPTS "s|(rm -rf .INSTALL_DIR.*)$|${REPLACEMENT_STRING}\1|g" ${DOCKER_FILE:-Dockerfile}
}

if [ -d 'dockerfiles' ]; then
  rm -rf dockerfiles;
fi

echo "##### Grabbing official Docker images from Oracle #####"
git clone https://github.com/fuzziebrain/docker-images.git tmp

mv tmp/OracleDatabase/SingleInstance/dockerfiles/ .

rm -rf tmp/

echo "##### Staging RPM #####"
if [ $DB_VERSION = '23.2.0' ]; then
  if [ $DB_EDITION = 'free' ]; then
    echo "Do nothing."
  fi
elif [ $DB_VERSION = '21.3.0' ]; then
  if [ $DB_EDITION = 'xe' ]; then
    DOCKER_FILE=Dockerfile.$DB_EDITION
    if [[ $XE_USE_LOCAL_COPY =~ (Y|y) ]]; then
      cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm
      sed $SED_OPTS "s|${XE_DOWNLOAD_BASE_URL}||g" ${DOCKER_FILE:-Dockerfile}
      sed $SED_OPTS "s|^(COPY)(.+CHECK_SPACE_FILE.+INSTALL_DIR/)$|\1 \$INSTALL_FILE_1\2|g" ${DOCKER_FILE:-Dockerfile}
    fi
  else
    cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/LINUX.X64_213000_db_home.zip
    DOCKER_FILE=Dockerfile
  fi
elif [ $DB_VERSION = '19.3.0' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/LINUX.X64_193000_db_home.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '18.4.0' ] && [ $DB_EDITION = 'xe' ]; then
  DOCKER_FILE=Dockerfile.$DB_EDITION
  if [[ $XE_USE_LOCAL_COPY =~ (Y|y) ]]; then
    cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/oracle-database-xe-18c-1.0-1.x86_64.rpm
    sed $SED_OPTS "s|${XE_DOWNLOAD_BASE_URL}||g" ${DOCKER_FILE:-Dockerfile}
    sed $SED_OPTS "s|^(COPY)(.+CHECK_SPACE_FILE.+INSTALL_DIR/)$|\1 \$INSTALL_FILE_1\2|g" ${DOCKER_FILE:-Dockerfile}
  fi
elif [ $DB_VERSION = '18.3.0' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/LINUX.X64_180000_db_home.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '12.2.0.1' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/linuxx64_12201_database.zip
  DOCKER_FILE=Dockerfile
elif [ $DB_VERSION = '12.1.0.2' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/linuxamd64_12102_database_1of2.zip
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/linuxamd64_12102_database_2of2.zip
  DOCKER_FILE=Dockerfile.$DB_EDITION
elif [ $DB_VERSION = '11.2.0.2' ]; then
  cd dockerfiles/$DB_VERSION && curl --progress-bar -O file://$FILES_DIR/oracle-xe-11.2.0-1.0.x86_64.rpm.zip
  DOCKER_FILE=Dockerfile.$DB_EDITION
else
  echo "Unknown or unsupported database version and/or edition."
fi

# TODO: test OML4R support for 21.3.0
if [[ $OML4R_SUPPORT =~ (Y|y) ]]; then
  if [[
    ($DB_VERSION = '19.3.0')
    || ($DB_VERSION = '18.4.0' && $DB_EDITION = 'xe')
    || ($DB_VERSION = '18.3.0')
    # || ($DB_VERSION = '12.2.0.1')
  ]]; then
    setupR
  fi
fi

cd $BASE_DIR

# RTU_ENABLED default 'N'
# The following is used for preparing "ready to use" images for internal use only.
if [[ $RTU_ENABLED =~ (Y|y) ]]; then
  echo "##### Modify target Dockerfile #####"
  REPLACEMENT_STRING=$'COPY scripts/setup/ \$ORACLE_BASE/scripts/setup/\\\nCOPY scripts/startup/ \$ORACLE_BASE/scripts/startup/\\\nCOPY files/ /tmp/files/\\\n'
  sed $SED_OPTS "s|^VOLUME.+$|${REPLACEMENT_STRING}|g" dockerfiles/${DB_VERSION}/${DOCKER_FILE:-Dockerfile}
  mkdir -p dockerfiles/${DB_VERSION}/files
  cp $FILES_DIR/$INSTALL_FILE_APEX $FILES_DIR/$INSTALL_FILE_ORDS $FILES_DIR/$INSTALL_FILE_JAVA dockerfiles/${DB_VERSION}/files/
  cp -R scripts dockerfiles/${DB_VERSION}/scripts
fi

# Retain the DBUA to allow DB patching. See https://github.com/oracle/docker-images/issues/1187
if [[ $ALLOW_DB_PATCHING =~ (Y|y) ]]; then
  echo "##### Preventing removal of DBUA #####"
  find dockerfiles -name installDBBinaries.sh -exec sed $SED_OPTS "s|^(\s*?rm.+ORACLE_HOME.+)$|#\1|g" {} \;
fi

echo "##### Building Docker Image for Oracle Database ${DB_VERSION} ${DB_EDITION} #####"
cd dockerfiles && . buildContainerImage.sh -v ${DB_VERSION} ${DB_EDITION_FLAG}

cd $BASE_DIR
echo "##### Done #####"
