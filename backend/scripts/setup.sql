-- Run as PostgreSQL superuser (e.g. postgres):
-- psql -U postgres -f scripts/setup.sql

CREATE USER shifter WITH PASSWORD 'shifter123';
CREATE DATABASE shifter OWNER shifter;
GRANT ALL PRIVILEGES ON DATABASE shifter TO shifter;
