#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv 

ORDS_CONFIG_DIR=$ORACLE_BASE/oradata/ordsconfig/$ORACLE_PDB

mkdir -p $ORDS_CONFIG_DIR 

cd $ORDS_HOME

cat << EOF > $ORDS_HOME/params/custom_params.properties
db.hostname=localhost
db.password=${ORACLE_PWD}
db.port=1521
db.servicename=${ORACLE_PDB:-XEPDB1}
db.username=APEX_PUBLIC_USER
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=SYSAUX
schema.tablespace.temp=TEMP
user.apex.listener.password=${ORACLE_PWD}
user.apex.restpublic.password=${ORACLE_PWD}
user.public.password=${ORACLE_PWD}
user.tablespace.default=SYSAUX
user.tablespace.temp=TEMP
sys.user=sys
sys.password=${ORACLE_PWD}
EOF

java -jar ords.war configdir $ORDS_CONFIG_DIR

java -jar ords.war install simple --parameterFile $ORDS_HOME/params/custom_params.properties
