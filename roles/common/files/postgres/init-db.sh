#!/usr/bin/env bash
set -e
psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<-EOSQL
	CREATE ROLE nuxeo NOSUPERUSER CREATEDB NOCREATEROLE INHERIT LOGIN;
	CREATE DATABASE nuxeo ENCODING 'UTF8' OWNER nuxeo;
        SET password_encryption = 'scram-sha-256';
        ALTER ROLE nuxeo WITH PASSWORD 'nuxeo';
	GRANT ALL PRIVILEGES ON DATABASE nuxeo TO nuxeo;
EOSQL
