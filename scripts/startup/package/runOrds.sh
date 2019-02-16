#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=XE

. oraenv 

APEX_IMAGE_PATH=$APEX_HOME/images

cd $ORDS_HOME

java -jar ords.war standalone \
  --port 8080 \
  --apex-images $APEX_IMAGE_PATH
