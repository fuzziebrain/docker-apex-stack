#!/bin/bash

CONTAINER_NAME=${1:-axer}
ENV_FILE=${2:-.env}

. $ENV_FILE

BASE_DIR=$(pwd -P)
DB_VERSION=${DB_VERSION:-18.4.0}
DB_EDITION=$(echo ${DB_EDITION:-xe} | tr '[:upper:]' '[:lower:]')
HOST_DATA_DIR=${CONTAINER_NAME}-oradata
DOCKER_NETWORK_NAME=${DOCKER_NETWORK_NAME:-bridge}

echo "##### Check if Docker network $DOCKER_NETWORK_NAME #####"
docker network inspect -f {{.Name}} $DOCKER_NETWORK_NAME || \
  echo "##### Create Docker network $DOCKER_NETWORK_NAME #####"; \
  docker network create $DOCKER_NETWORK_NAME 

echo "##### Removing any previous containers #####"
docker rm -vf $CONTAINER_NAME

if [ ! -d "${HOST_DATA_DIR}" ] && ! [[ $RTU_ENABLED =~ ^(Y|y)$ ]]; then
  mkdir $HOST_DATA_DIR
fi

echo "##### Changing file ownership. May require password to continue. #####"
if ! [[ $RTU_ENABLED =~ ^(Y|y)$ ]]; then
  sudo -n chown 54321:543321 ${HOST_DATA_DIR} || chmod 777 ${HOST_DATA_DIR}
fi
 
echo "##### Creating container $CONTAINER_NAME #####"
if [[ $RTU_ENABLED =~ ^(Y|y)$ ]]; then
  docker run -d --name $CONTAINER_NAME \
          --network ${DOCKER_NETWORK_NAME} \
          -p ${DOCKER_ORDS_PORT:-50080}:8080 \
          -p ${DOCKER_EM_PORT:-55500}:5500 \
          -p ${DOCKER_DB_PORT:-51521}:1521 \
          --env-file $ENV_FILE \
          oracle/database:${DB_VERSION}-${DB_EDITION}
else
  docker run -d --name $CONTAINER_NAME \
          --network ${DOCKER_NETWORK_NAME} \
          -p ${DOCKER_ORDS_PORT:-50080}:8080 \
          -p ${DOCKER_EM_PORT:-55500}:5500 \
          -p ${DOCKER_DB_PORT:-51521}:1521 \
          --env-file $ENV_FILE \
          -v $PWD/$HOST_DATA_DIR:/opt/oracle/oradata \
          -v $PWD/scripts/setup:/opt/oracle/scripts/setup \
          -v $PWD/scripts/startup:/opt/oracle/scripts/startup \
          -v $PWD/files:/tmp/files \
          oracle/database:${DB_VERSION}-${DB_EDITION}
fi

echo "##### Tailing logs. Ctrl-C to exit. #####"
docker logs -f $CONTAINER_NAME
