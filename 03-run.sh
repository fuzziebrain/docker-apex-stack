#!/bin/bash

CONTAINER_NAME=${1:-axer}
ENV_FILE=${2:-.env}

echo "##### Removing any previous containers #####"
docker rm -vf $CONTAINER_NAME

if [ ! -d "oradata" ]; then
  mkdir oradata
fi

echo "##### Changing file ownership. May require password to continue. #####"
sudo chown 54321:54321 oradata

echo "##### Creating container $CONTAINER_NAME #####"
docker run -d --name $CONTAINER_NAME \
        -p 50080:8080 \
        -p 5500:5500 \
        -p 51521:1521 \
        --env-file $ENV_FILE \
        -v $PWD/oradata:/opt/oracle/oradata \
        -v $PWD/scripts/setup:/opt/oracle/scripts/setup \
        -v $PWD/scripts/startup:/opt/oracle/scripts/startup \
        -v $PWD/files:/tmp/files \
        oracle/database:18.4.0-xe

echo "##### Tailing logs. Ctrl-C to exit. #####"
docker logs -f $CONTAINER_NAME