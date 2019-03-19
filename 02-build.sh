#!/bin/bash

ENV_FILE=${1:-.env}

. $ENV_FILE

BASE_DIR=$(readlink -f -- "$0" | xargs dirname)
DB_VERSION=${DB_VERSION:-18.4.0}
DB_EDITION=${DB_EDITION:-XE}

case "$DB_EDITION" in
  "EE")
    DB_EDITION_FLAG=-e
    ;;
  "SE")
    DB_EDITION_FLAG=-s
    ;;
  *)
    DB_EDITION_FLAG=-x
    ;;
esac

echo "##### Building Docker Image for Oracle Database ${DB_VERSION} {$DB_EDITION} #####"
cd dockerfiles && . buildDockerImage.sh -v ${DB_VERSION} ${DB_EDITION_FLAG}

cd $BASE_DIR
echo "##### Done #####"
