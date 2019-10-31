#!/bin/bash

# Run as oracle user

ORAENV_ASK=NO
ORACLE_SID=${ORACLE_SID:-XE}

. oraenv

cd $APEX_HOME

echo "Post-Installation Task for APEX and ORDS"
sqlplus / as sysdba << EOF
  alter session set container = ${ORACLE_PDB:-XEPDB1};

  -- Create profile APPLICATION_AGENT
  create profile application_agent limit
    cpu_per_session unlimited
    cpu_per_call unlimited
    connect_time unlimited
    idle_time unlimited
    sessions_per_user unlimited
    logical_reads_per_session unlimited
    logical_reads_per_call unlimited
    private_sga unlimited
    composite_limit unlimited
    password_life_time unlimited
    password_grace_time 7
    password_reuse_max unlimited
    password_reuse_time unlimited
    password_verify_function null
    failed_login_attempts 10
    password_lock_time 1
  ;
  -- Assign relevant users so that their passwords do not expire
  alter user apex_public_user profile application_agent;
  alter user apex_rest_public_user profile application_agent;
  alter user apex_listener profile application_agent;
  alter user ords_public_user profile application_agent;
EOF
