{ db_name ? "elixir_dev" }:

''
  export PGDATA=$(mktemp --directory)

  # PG_LISTENING_ADDRESS
  : ''${PG_LISTENING_ADDRESS:=127.0.0.1}

  # DB only listening on socket 
  if [ "$MIX_ENV" = 'test' ]
  then
    export PG_LISTENING_ADDRESS="'''"
  fi

  initdb --locale=C --encoding=UTF8 --auth-local=peer --auth-host=scram-sha-256 > /dev/null || exit

  pg_ctl -l $PGDATA/postgresql.log -o "-k $PGDATA -h $PG_LISTENING_ADDRESS" start || exit

  createdb -h $PGDATA ${db_name}
  psql -h $PGDATA ${db_name} -c "COMMENT ON DATABASE ${db_name} IS 'Database for Development, Testing & CI'" > /dev/null

  # createuser: postgres w default password
  psql -h $PGDATA ${db_name} -c "CREATE USER postgres PASSWORD 'postgres'" > /dev/null

  cleanup() {
    pg_ctl stop --silent
    rm -rf $PGDATA
  }

  trap cleanup EXIT
''
