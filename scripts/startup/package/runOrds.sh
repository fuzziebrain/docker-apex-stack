#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv 

ORDS_CONFIG_DIR=$ORACLE_BASE/oradata/ordsconfig/$ORACLE_PDB
APEX_IMAGE_PATH=$APEX_HOME/images

cd $ORDS_HOME

java -jar ords.war configdir $ORDS_CONFIG_DIR

java -jar ords.war standalone \
  --port 8080 \
  --apex-images $APEX_IMAGE_PATH
