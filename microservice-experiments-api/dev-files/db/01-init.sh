#!/bin/sh
set -e
export PGPASSWORD=$POSTGRES_PASS;
echo "Show Existing Databases... "
psql -lqt ;

if psql -lqt | cut -d \| -f 1 | grep -qw ${APP_DB_NAME}; then
  echo "Database ${APP_DB_NAME} exists - nothing to create";
else
  echo "Database ${APP_DB_NAME} does not exist - creating one";

  psql -v ON_ERROR_STOP=1 --username ${POSTGRES_USER} --dbname ${POSTGRES_DB} <<- EOSQL
    CREATE USER $APP_DB_USER WITH PASSWORD '$APP_DB_PASS';
    CREATE DATABASE $APP_DB_NAME;
    GRANT ALL PRIVILEGES ON DATABASE $APP_DB_NAME TO $APP_DB_USER;

    \connect $APP_DB_NAME $APP_DB_USER;
    CREATE SCHEMA $APP_DB_SCHEMA_NAME AUTHORIZATION $APP_DB_USER;
    CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOSQL
fi

echo "Execute additional SQL scripts"
psql -v ON_ERROR_STOP=1 --username ${POSTGRES_USER} --dbname ${POSTGRES_DB} <<- EOSQL
  \connect $APP_DB_NAME $APP_DB_USER;
  BEGIN;
    -- Enter additional SQL scripts here for local testing if needed.
    -- Do not commit your added scripts to keep this file easy to use.
  COMMIT;
EOSQL
