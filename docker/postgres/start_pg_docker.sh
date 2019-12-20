#!/bin/bash

# Prior to first use, run:
# docker volume create family_loop-postgres

# FIXME Don't use this for production!
docker container run --name fam_loop-pg -p 5432:5432 \
  -e POSTGRESPASSWORD=postgres \
  -e POSTGRESUSER=postgres \
  -v family_loop-postgres:/var/lib/postgresql/data \
  -d postgres:12.1-alpine

# psql
# docker container exec -it fam_loop-pg psql -U postgres