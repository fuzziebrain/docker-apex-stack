#!/bin/bash

# Run as oracle

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}
ORACLE_PDB=${ORACLE_PDB:-XEPDB1}
R_HOME=/usr/lib64/R

. oraenv

chmod a+x ${ORACLE_HOME}/bin/ORE

${ORACLE_HOME}/bin/ORE -e "install.packages(c('png','DBI','ROracle','randomForest','statmod','Cairo'))"
${ORACLE_HOME}/bin/ORE -e "install.packages('https://cran.r-project.org/src/contrib/Archive/arules/arules_1.1-9.tar.gz',repos=NULL,type='source')"

cd $ORACLE_HOME/R/server

sqlplus -s / as sysdba << EOF
  alter session set container = $ORACLE_PDB;
  @rqcfg SYSAUX TEMP $ORACLE_HOME $R_HOME
EOF