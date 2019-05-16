#!/bin/bash

export SCRIPT_DIR=$SCRIPTS_ROOT

if [ "$DB_VERSION" = "18.4.0" ] && [ "$DB_EDITION" = "xe" ]; then
  echo "##### Enable EM Access for ${DB_VERSION} ${DB_EDITION} #####"
  runuser oracle -m -s /bin/bash -c ". $SCRIPT_DIR/package/enableEmAccess.sh"
fi
