#!/usr/bin/env bash
# Use bash quickerstart.sh myemail@example.com Testpassword123 dockerapex21xe mysetting.env   
##### Create environment variables file. #####
APEX_ADMIN_EMAIL=$1
ORACLE_PWD=$2
CONTAINER_NAME=$3
ENV_FILE_NAME=$4

cat << EOF > $ENV_FILE_NAME
ORACLE_SID=XE
ORACLE_PDB=XEPDB1
ORACLE_PWD=$ORACLE_PWD
APEX_ADMIN_EMAIL=$APEX_ADMIN_EMAIL
APEX_ADMIN_PWD=$ORACLE_PWD
APEX_PUBLIC_USER_PWD=$ORACLE_PWD
APEX_LISTENER_PWD=$ORACLE_PWD
APEX_REST_PUBLIC_USER_PWD=$ORACLE_PWD
ORDS_PUBLIC_USER_PWD=$ORACLE_PWD
INSTALL_FILE_APEX=apex-latest.zip
INSTALL_FILE_ORDS=ords-latest.zip
INSTALL_FILE_JAVA=jdk-17_linux-x64_bin.tar.gz
DOCKER_ORDS_PORT=50080
DOCKER_EM_PORT=55500
DOCKER_DB_PORT=51521
DB_VERSION=21.3.0
DB_EDITION=xe
DOCKER_NETWORK_NAME=das_network
ALLOW_DB_PATCHING=N
OML4R_SUPPORT=N
REST_ENABLED_SQL=Y
RTU_ENABLED=N
SQLDEVWEB=Y
DATABASEAPI=Y
FILES_DIR=/files
XE_USE_LOCAL_COPY=N
EOF

##### Download files #####
echo "##### Downloading latest binaries for APEX and ORDS #####"
curl https://download.oracle.com/otn_software/apex/apex-latest.zip --output files/apex-latest.zip
curl https://download.oracle.com/otn_software/java/ords/ords-latest.zip --output files/ords-latest.zip
curl https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz --output files/jdk-17_linux-x64_bin.tar.gz

echo "Set Permissions"
sudo chmod +x 01-build.sh
sudo chmod +x 02-run.sh

echo "##### Running the build #####"
# bash ./01-build.sh $ENV_FILE_NAME 2>&1 | tee 01-build.log
bash ./01-build.sh $ENV_FILE_NAME &> /dev/null

echo "##### Deploying the container #####"
# bash ./02-run.sh ${CONTAINER_NAME} $ENV_FILE_NAME 2>&1 | tee 02-run.log
bash ./02-run.sh ${CONTAINER_NAME} $ENV_FILE_NAME &> /dev/null 

echo "Finished"