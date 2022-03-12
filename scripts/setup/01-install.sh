#!/bin/bash

export APEX_HOME=$ORACLE_BASE/product/apex
export ORDS_HOME=$ORACLE_BASE/product/ords
export SCRIPT_DIR=$SCRIPTS_ROOT
export FILES_DIR=/tmp/files

echo "##### Install dependencies if required #####"
if [ ! $(command -v java) ]; then
  if [[ $UID == "0" && $INSTALL_FILE_JAVA == 'java17' ]]; then
    yum install -y https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
  elif [[ $UID == "0" && $INSTALL_FILE_JAVA == 'openjdk1.8' ]]; then
    yum install -y java-1.8.0-openjdk
  elif [[ $UID == "0" && $INSTALL_FILE_JAVA == 'openjdk11' ]]; then
    yum install -y java-11-openjdk
  else
    export JAVA_HOME=$ORACLE_BASE/product/java/latest
    export PATH=$JAVA_HOME/bin:$PATH

    if [[ ! $FILENAME =~ .tar.gz$ ]]; then
      export INSTALL_FILE_JAVA="jdk-17_linux-x64_bin.tar.gz"
      wget https://download.oracle.com/java/17/latest/$INSTALL_FILE_JAVA \
        -o $FILES_DIR/$INSTALL_FILE_JAVA
    fi

    if [ ! -d $JAVA_HOME ]; then
      JAVA_DIR_NAME=`tar -tzf $FILES_DIR/$INSTALL_FILE_JAVA | head -1 | cut -f1 -d"/"`
      mkdir -p $ORACLE_BASE/product/java
      tar zxf $FILES_DIR/$INSTALL_FILE_JAVA --directory $ORACLE_BASE/product/java
      ln -s $ORACLE_BASE/product/java/$JAVA_DIR_NAME $JAVA_HOME
    fi
  fi
fi

if [[ $OML4R_SUPPORT =~ (Y|y) ]]; then
  if [[
    ($DB_VERSION = '19.3.0')
    || ($DB_VERSION = '18.4.0' && $DB_EDITION = 'xe')
    || ($DB_VERSION = '18.3.0')
    # || ($DB_VERSION = '12.2.0.1')
  ]]; then
    echo "##### Install ORE dependencies and configure ORE DB support #####"
    if [ $UID = "0" ]; then
      runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/enableORE.sh"
    else
      . $SCRIPT_DIR/package/enableORE.sh
    fi
  fi
fi

# Extract files
echo "##### Extracting files ####"
mkdir -p $ORDS_HOME
unzip -q $FILES_DIR/$INSTALL_FILE_APEX -d $ORACLE_BASE/product
unzip -q $FILES_DIR/$INSTALL_FILE_ORDS -d $ORDS_HOME
chown -R oracle:oinstall $APEX_HOME $ORDS_HOME

# Set apex_rest_config prefix if required
APEX_VERSION=$(echo $INSTALL_FILE_APEX | sed -r 's/^apex_(.+)\.zip$/\1/')
case "$APEX_VERSION" in
4.*|5.*|18.1)
  # DO NOT add prefix for apex_rest_config
  ;;
*)
  export PREFIX=@
  ;;
esac

# Install APEX
echo "##### Installing APEX #####"
if [ $UID = "0" ]; then
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/installApex.sh"
else
  . $SCRIPT_DIR/package/installApex.sh
fi

# Install ORDS
echo "##### Installing ORDS #####"
if [ $UID = "0" ]; then
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/installOrds.sh"
else
  . $SCRIPT_DIR/package/installOrds.sh
fi

# Post-installation Tasks for APEX and ORDS
if [ $UID = "0" ]; then
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/postInstallApexOrds.sh"
else
  . $SCRIPT_DIR/package/postInstallApexOrds.sh
fi

# Setup Oracle Wallet for APEX
if [ $UID = "0" ]; then
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/setupBaseWallet.sh"
else
  . $SCRIPT_DIR/package/setupBaseWallet.sh
fi