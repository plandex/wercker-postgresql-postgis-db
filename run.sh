#!/bin/sh

if [ ! -n "$WERCKER_POSTGRESQL_USERNAME" ]; then
    export WERCKER_POSTGRESQL_USERNAME=postgres
fi
if [ ! -n "$WERCKER_POSTGRESQL_PASSWORD" ]; then
    export WERCKER_POSTGRESQL_PASSWORD=wercker
fi
if [ ! -n "$WERCKER_POSTGRESQL_PORT" ]; then
    export WERCKER_POSTGRESQL_PORT=5432
fi
if [ ! -n "$WERCKER_POSTGRESQL_DATABASE" ]; then
    export WERCKER_POSTGRESQL_DATABASE=werckerdb
fi
if [ ! -n "$WERCKER_POSTGRESQL_HOST" ]; then
    export WERCKER_POSTGRESQL_HOST=$HOST
fi
if [ ! -n "$WERCKER_POSTGRESQL_HOST" ]; then
    export WERCKER_POSTGRESQL_HOST=localhost
fi
if [ ! -n "$WERCKER_POSTGRESQL_URL" ]; then
    export WERCKER_POSTGRESQL_URL="postgres://${WERCKER_POSTGRESQL_USERNAME}:${WERCKER_POSTGRESQL_PASSWORD}@${WERCKER_POSTGRESQL_HOST}:${WERCKER_POSTGRESQL_PORT}/${WERCKER_POSTGRESQL_DATABASE}${TEST_ENV_NUMBER}"
fi

echo "postgres network connections:"
netstat -na | grep "${WERCKER_POSTGRESQL_PORT}"
echo "creating postgres database ${WERCKER_POSTGRESQL_USERNAME}:***@${WERCKER_POSTGRESQL_HOST}:${WERCKER_POSTGRESQL_PORT}/${WERCKER_POSTGRESQL_DATABASE} with postgis extensions"

sudo -- su postgres -c "PGPASSWORD=${WERCKER_POSTGRESQL_PASSWORD} createdb -h ${WERCKER_POSTGRESQL_HOST} -p ${WERCKER_POSTGRESQL_PORT} -U postgres -O postgres werkerdb$TEST_ENV_NUMBER"
sudo -- su postgres -c "PGPASSWORD=${WERCKER_POSTGRESQL_PASSWORD} psql -c 'CREATE EXTENSION postgis;' -U postgres -d werckerdb$TEST_ENV_NUMBER -h ${WERCKER_POSTGRESQL_HOST} -p ${WERCKER_POSTGRESQL_PORT}"
sudo -- su postgres -c "PGPASSWORD=${WERCKER_POSTGRESQL_PASSWORD} psql -c 'CREATE EXTENSION postgis_topology;' -U postgres -d werckerdb$TEST_ENV_NUMBER -h ${WERCKER_POSTGRESQL_HOST} -p ${WERCKER_POSTGRESQL_PORT}"
