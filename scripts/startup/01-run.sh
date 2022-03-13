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

    if [ ! -d $JAVA_HOME ]; then
      if [[ ! $FILENAME =~ .tar.gz$ ]]; then
        INSTALL_FILE_JAVA_DEFAULT="jdk-17_linux-x64_bin.tar.gz"
        curl https://download.oracle.com/java/17/latest/$INSTALL_FILE_JAVA_DEFAULT \
          --output /tmp/$INSTALL_FILE_JAVA_DEFAULT
        JAVA_DIR_NAME=`tar -tzf /tmp/$INSTALL_FILE_JAVA_DEFAULT | head -1 | cut -f1 -d"/"`
        mkdir -p $ORACLE_BASE/product/java
        tar zxf /tmp//$INSTALL_FILE_JAVA_DEFAULT --directory $ORACLE_BASE/product/java
        ln -s $ORACLE_BASE/product/java/$JAVA_DIR_NAME $JAVA_HOME
        rm -f /tmp/$INSTALL_FILE_JAVA_DEFAULT
      else
        JAVA_DIR_NAME=`tar -tzf $FILES_DIR/$INSTALL_FILE_JAVA | head -1 | cut -f1 -d"/"`
        mkdir -p $ORACLE_BASE/product/java
        tar zxf $FILES_DIR/$INSTALL_FILE_JAVA --directory $ORACLE_BASE/product/java
        ln -s $ORACLE_BASE/product/java/$JAVA_DIR_NAME $JAVA_HOME
      fi
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
    echo "##### Install ORE dependencies if necessary #####"
    if [ $UID = "0" ]; then
      runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/installOreDeps.sh"
    else
      . $SCRIPT_DIR/package/installOreDeps.sh
    fi
  fi
fi

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
if [ $UID = "0" ]; then
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/runOrds.sh"
else
  . $SCRIPT_DIR/package/runOrds.sh
fi