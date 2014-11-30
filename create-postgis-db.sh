#!/bin/bash

dbname="${WERCKER_POSTGRESQL_DATABASE}${TEST_ENV_NUMBER}"
user="${WERCKER_POSTGRESQL_USERNAME}"
password="${WERCKER_POSTGRESQL_PASSWORD}"

sudo -- su postgres -c "createdb -O ${user} ${dbname}"

if [ -n "$WERCKER_POSTGRESQL_HOST" ]; then
    if [ ! -n "$WERCKER_POSTGRESQL_URL" ]; then
        export WERCKER_POSTGRESQL_URL="postgres://${user}:${password}@${WERCKER_POSTGRESQL_HOST}:${WERCKER_POSTGRESQL_PORT}/${dbname}"
    fi

    if sudo grep -Exq '^host\s+${dbname}\s+${user}\s+0\.0\.0\.0\/32\s+\w+' /etc/postgresql/9.3/main/pg_hba.conf; then
        sudo sed -i -r -e 's/host\s+${dbname}\s+${user}\s+0\.0\.0\.0\/32\s+\w+/host ${dbname} ${user} 0.0.0.0/32 md5/' /etc/postgresql/9.3/main/pg_hba.conf
    else
        sudo -- sh -c "echo 'host ${dbname} ${user} 0.0.0.0/32 md5' >> /etc/postgresql/9.3/main/pg_hba.conf"
    fi
else
    if [ ! -n "$WERCKER_POSTGRESQL_URL" ]; then
        export WERCKER_POSTGRESQL_URL="postgres://${user}:${password}@${dbname}"
    fi

    if sudo grep -Exq '^local\s+${dbname}\s+${user}\s+\w+' /etc/postgresql/9.3/main/pg_hba.conf; then
        sudo sed -i -r -e 's/local\s+${dbname}\s+${user}\s+\w+/local ${dbname} ${user}  md5/' /etc/postgresql/9.3/main/pg_hba.conf
    else
        sudo -- sh -c "echo 'local ${dbname} ${user}  md5' >> /etc/postgresql/9.3/main/pg_hba.conf"
    fi
fi

sudo service postgresql restart

if [ -n "$WERCKER_POSTGRESQL_HOST" ]; then
    echo "creating postgres database ${user}:*****@${WERCKER_POSTGRESQL_HOST}:${WERCKER_POSTGRESQL_PORT}/${dbname} with postgis extensions"
    PGPASSWORD="${password}" psql -c 'CREATE EXTENSION postgis;' -U "${user}" -d "${dbname}" -h $WERCKER_POSTGRESQL_HOST -p $WERCKER_POSTGRESQL_PORT
    PGPASSWORD="${password}" psql -c 'CREATE EXTENSION postgis_topology;' -U "${user}" -d "${dbname}" -h $WERCKER_POSTGRESQL_HOST -p $WERCKER_POSTGRESQL_PORT
else
    echo "creating postgres database ${user}:*****@${dbname} with postgis extensions"
    sudo -- su "${user}" -c "PGPASSWORD=${password} psql -c 'CREATE EXTENSION postgis;' -d ${dbname}"
    sudo -- su "${user}" -c "PGPASSWORD=${password} psql -c 'CREATE EXTENSION postgis_topology;' -d ${dbname}"
fi

echo -n "Checking if database created... "
if sudo -- su postgres -c "psql -c 'SELECT datname FROM pg_database WHERE datistemplate=false;'" | grep -Eqx "\s*${WERCKER_POSTGRESQL_DATABASE}"; then
    echo "yes"
else
    echo "no"
    exit 1
fi

echo -n "Checking if postgis extension created... "
if sudo -- su postgres -c "psql -d ${WERCKER_POSTGRESQL_DATABASE} -c 'SELECT PostGIS_full_version();'" | grep -q "POSTGIS="; then
    echo "yes"
else
    echo "no"
    exit 1
fi
