#!/bin/bash

BASE_DIR=$(readlink -f $0 | xargs dirname)

if [ -d 'dockerfiles' ]; then
  rm -rf dockerfiles;
fi

echo "##### Grabbing official Docker images from Oracle #####"
git clone https://github.com/oracle/docker-images.git tmp

mv tmp/OracleDatabase/SingleInstance/dockerfiles/ .

rm -rf tmp/

echo "##### Staging RPM #####"
cd dockerfiles/18.4.0 && curl --progress-bar -O file://$BASE_DIR/files/oracle-database-xe-18c-1.0-1.x86_64.rpm

cd $BASE_DIR
echo "##### Done #####"