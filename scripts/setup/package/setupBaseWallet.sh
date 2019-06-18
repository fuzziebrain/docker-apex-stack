#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv 

export WALLET_BASE_PATH=$ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/wallets
export BUNDLE_FILE=/etc/pki/tls/cert.pem
export WALLET_PATH=$WALLET_BASE_PATH/tls_wallet
export WALLET_PWD=$ORACLE_PWD
export WALLET_PWD_CONFIRM=$WALLET_PWD

if [ ! -d $WALLET_BASE_PATH ]; then
  mkdir -p $WALLET_BASE_PATH
fi

sh -c "$(curl -fsSL https://gist.githubusercontent.com/fuzziebrain/202f902d8fc6d8de586da5097a501047/raw/78dba192f4c15f59d14ac17491734897fc440e40/createBaseWallet.sh)"

echo "Setup APEX Wallet"
sqlplus / as sysdba << EOF
  alter session set container = ${ORACLE_PDB:-XEPDB1};

  begin
    apex_instance_admin.set_parameter(
      p_parameter => 'WALLET_PATH'
      , p_value => 'file:$WALLET_PATH'
    );

    apex_instance_admin.set_parameter(
      p_parameter => 'WALLET_PWD'
      , p_value => '$WALLET_PWD'
    );

    commit;
  end;
  /
EOF
