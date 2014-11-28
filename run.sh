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
if [ ! -n "$WERCKER_POSTGRESQL_URL" ]; then
    export WERCKER_POSTGRESQL_URL="postgres://${WERCKER_POSTGRESQL_USERNAME}:${WERCKER_POSTGRESQL_PASSWORD}@${HOST}:${WERCKER_POSTGRESQL_PORT}/${WERCKER_POSTGRESQL_DATABASE}${TEST_ENV_NUMBER}"
fi
if [ ! -n "$WERCKER_POSTGRESQL_HOST" ]; then
    export WERCKER_POSTGRESQL_HOST=$HOST
fi

sudo -- su postgres -c "createdb werkerdb$TEST_ENV_NUMBER -U postgres"
sudo -- su postgres -c "psql -c 'CREATE EXTENSION postgis;' -U postgres -d werckerdb$TEST_ENV_NUMBER"
sudo -- su postgres -c "psql -c 'CREATE EXTENSION postgis_topology;' -U postgres -d werckerdb$TEST_ENV_NUMBER"
