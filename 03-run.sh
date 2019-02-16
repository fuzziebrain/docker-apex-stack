#!/bin/bash

CONTAINER_NAME=${1:-axer}
ENV_FILE=${2:-.env}

docker rm -vf $CONTAINER_NAME

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

docker logs -f $CONTAINER_NAME