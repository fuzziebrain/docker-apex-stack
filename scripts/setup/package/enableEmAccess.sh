#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv 

GLOBAL_ACCESS=${GLOBAL_ACCESS:-Y}

if [ $GLOBAL_ACCESS = "Y" ]; then 
  GLOBAL_ACCESS="true"
else
  GLOBAL_ACCESS="false"
fi;

echo "##### Enabling XDB for external access #####"
sqlplus / as sysdba << EOF
  exec dbms_xdb_config.setlistenerlocalaccess(false);
  exec dbms_xdb_config.setglobalportenabled($GLOBAL_ACCESS);
EOF