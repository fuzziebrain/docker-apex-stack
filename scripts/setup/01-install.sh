#!/bin/bash

export APEX_HOME=$ORACLE_BASE/product/apex
export ORDS_HOME=$ORACLE_BASE/product/ords
export SCRIPT_DIR=$SCRIPTS_ROOT
export FILES_DIR=/tmp/files
export JAVA_HOME=$ORACLE_BASE/product/java/latest
export PATH=$JAVA_HOME/bin:$PATH

case "${INSTALL_FILE_JAVA}" in
  openjdk11) DOWNLOAD_URL=https://download.java.net/java/ga/jdk11/openjdk-11_linux-x64_bin.tar.gz;;
  *.tar.gz) ;;
  *) DOWNLOAD_URL=https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz;;
esac

if [ ! -z "${DOWNLOAD_URL}" ]; then
  export INSTALL_FILE_JAVA="${DOWNLOAD_URL##*/}"
fi

echo "##### Install dependencies if required #####"
if [ ! -d $JAVA_HOME ]; then
  if [ ! -f "$FILES_DIR/$INSTALL_FILE_JAVA" ]; then
    curl --output $FILES_DIR/$INSTALL_FILE_JAVA ${DOWNLOAD_URL}
  fi
  JAVA_DIR_NAME=`tar -tzf $FILES_DIR/$INSTALL_FILE_JAVA | head -1 | cut -f1 -d"/"`
  mkdir -p $ORACLE_BASE/product/java
  tar zxf $FILES_DIR/$INSTALL_FILE_JAVA --directory $ORACLE_BASE/product/java
  ln -s $ORACLE_BASE/product/java/$JAVA_DIR_NAME $JAVA_HOME

  echo -e 'export JAVA_HOME=$ORACLE_BASE/product/java/latest' >> $HOME/.bashrc
  echo -e 'export PATH=$JAVA_HOME/bin:$PATH' >> $HOME/.bashrc
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