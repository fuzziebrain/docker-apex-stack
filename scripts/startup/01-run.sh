#!/bin/bash

export APEX_HOME=$ORACLE_BASE/product/apex
export ORDS_HOME=$ORACLE_BASE/product/ords
export SCRIPT_DIR=$SCRIPTS_ROOT
export FILES_DIR=/tmp/files

echo "##### Install dependencies #####"
yum install -y java-1.8.0-openjdk

# Extract files
echo "##### Extracting files if required ####"

if [ ! -d $APEX_HOME ]; then
    echo "##### Unpacking APEX files #####"
  unzip -q $FILES_DIR/$INSTALL_FILE_APEX -d $ORACLE_BASE/product
  chown -R oracle:oinstall $APEX_HOME
fi

if [ ! -d $ORDS_HOME ]; then
  echo "##### Unpacking ORDS files #####"
  mkdir -p $ORDS_HOME
  unzip -q $FILES_DIR/$INSTALL_FILE_ORDS -d $ORDS_HOME
  chown -R oracle:oinstall $ORDS_HOME
fi

# Run ORDS
echo "##### Starting ORDS #####"
runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/runOrds.sh"
