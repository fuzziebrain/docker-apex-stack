#!/bin/bash

export APEX_HOME=$ORACLE_BASE/product/apex
export ORDS_HOME=$ORACLE_BASE/product/ords
export SCRIPT_DIR=$SCRIPTS_ROOT

# Run ORDS
echo "##### Starting ORDS #####"
runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/runOrds.sh"
