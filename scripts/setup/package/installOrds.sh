#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv

ORDS_CONFIG_DIR=$ORACLE_BASE/oradata/ordsconfig/$ORACLE_PDB

mkdir -p $ORDS_CONFIG_DIR

cd $ORDS_HOME

PARAM_FILE=$ORDS_HOME/params/custom_params.properties

cat << EOF > $PARAM_FILE
db.hostname=localhost
db.password=${APEX_PUBLIC_USER_PWD:-$ORACLE_PWD}
db.port=1521
db.servicename=${ORACLE_PDB:-XEPDB1}
db.username=APEX_PUBLIC_USER
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=SYSAUX
schema.tablespace.temp=TEMP
user.apex.listener.password=${APEX_LISTENER_PWD:-$ORACLE_PWD}
user.apex.restpublic.password=${APEX_REST_PUBLIC_USER_PWD:-$ORACLE_PWD}
user.public.password=${ORDS_PUBLIC_USER_PWD:-$ORACLE_PWD}
user.tablespace.default=SYSAUX
user.tablespace.temp=TEMP
sys.user=sys
sys.password=${ORACLE_PWD}
standalone.mode=false
EOF

# If SQLDEVWEB = Y, then REST_ENABLED_SQL must be Y
if [[ $SQLDEVWEB =~ (Y|y) || $REST_ENABLED_SQL =~ (Y|y) || $DATABASEAPI =~ (Y|y) ]]; then
    echo "restEnabledSql.active=true" >> $PARAM_FILE
fi

if [[ $SQLDEVWEB =~ (Y|y) ]]; then
    echo "feature.sdw=true" >> $PARAM_FILE
fi

if [[ $DATABASEAPI =~ (Y|y) ]]; then
    echo "database.api.enabled=true" >> $PARAM_FILE
fi

java -jar ords.war configdir $ORDS_CONFIG_DIR

java -jar ords.war install simple --parameterFile $ORDS_HOME/params/custom_params.properties
