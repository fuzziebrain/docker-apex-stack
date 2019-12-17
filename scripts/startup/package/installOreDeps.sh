#!/bin/bash

# Run as oracle

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv

${ORACLE_HOME}/bin/ORE -e "source('$SCRIPT_DIR/package/installRequiredPackages.R')"
