#!/usr/bin/env bash


##### Functions #####
function generate_password() {
    # SC => special characters allowed
    SC="_"
    while
        _password=$(openssl rand -base64 $(($RANDOM % 6 + 15)) | tr '[:punct:]' $SC)
        [[
            $(echo $_password | grep -o '['$SC']' | wc -l) -lt 2
            || $(echo $_password | grep -o '[0-9]' | wc -l) -lt 2
            || $(echo $_password | grep -o '[A-Z]' | wc -l) -lt 2
            || $(echo $_password | grep -o '[a-z]' | wc -l) -lt 2
        ]]
    do true; done

    echo $_password
}

##### Prompt for required variables #####
while
    echo -n "Enter an email address for your APEX administrator (required): "
    read APEX_ADMIN_EMAIL
    [[ -z $APEX_ADMIN_EMAIL ]]
do true; done

echo -n "Container name (leave empty to have one generated for you): "
read CONTAINER_NAME

##### Create environment variables file. #####
ORACLE_PWD=$(generate_password)
[[ -z $CONTAINER_NAME ]] && CONTAINER_NAME=das-qs-$(date +%s)
ENV_FILE_NAME=$CONTAINER_NAME.env

##### Print out Oracle password #####
echo "##### Important Information #####"
echo "Your Docker container name is: $CONTAINER_NAME"
echo "Your password for the database and APEX internal workspace is: $ORACLE_PWD"
echo ""

while
    echo "We are now ready to build the Docker image and deploy your container."
    echo -n "Type \"Y\" to continue or CTRL-C to exit: "
    read CONTINUE
    [[ ! $CONTINUE =~ (Y|y) ]]
do true; done

cat << EOF > $ENV_FILE_NAME
ORACLE_SID=XE
ORACLE_PDB=XEPDB1
ORACLE_PWD=$ORACLE_PWD
APEX_ADMIN_PWD=$ORACLE_PWD
APEX_PUBLIC_USER_PWD=$ORACLE_PWD
APEX_LISTENER_PWD=$ORACLE_PWD
APEX_REST_PUBLIC_USER_PWD=$ORACLE_PWD
ORDS_PUBLIC_USER_PWD=$ORACLE_PWD
INSTALL_FILE_APEX=apex-latest.zip
INSTALL_FILE_ORDS=ords-latest.zip
INSTALL_FILE_JAVA=openjdk11
DOCKER_ORDS_PORT=50080
DOCKER_EM_PORT=55500
DOCKER_DB_PORT=51521
DB_VERSION=18.4.0
DB_EDITION=xe
DOCKER_NETWORK_NAME=das_network
ALLOW_DB_PATCHING=N
OML4R_SUPPORT=N
REST_ENABLED_SQL=Y
RTU_ENABLED=N
SQLDEVWEB=Y
DATABASEAPI=Y
EOF

##### Download files #####
echo "##### Downloading latest binaries for APEX and ORDS #####"
curl https://download.oracle.com/otn_software/apex/apex-latest.zip --output files/apex-latest.zip
curl https://download.oracle.com/otn_software/java/ords/ords-latest.zip --output files/ords-latest.zip

echo "##### Running the build #####"
bash ./01-build.sh $ENV_FILE_NAME 2>&1 | tee 01-build.log

echo "##### Deploying the container #####"
bash ./02-run.sh ${CONTAINER_NAME} $ENV_FILE_NAME 2>&1 | tee 02-run.log
