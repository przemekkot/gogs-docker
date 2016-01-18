#!/bin/bash
# Copyright 2015 Jubic Oy
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# 		http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

mysql_exec () {
  mysql -u root "-p${MGOGS_DB_ROOT_PASSWORD}" "-h${MGOGS_DB_HOST%:*}" "-P${MGOGS_DB_HOST##*:}"
  #{ while read line; do echo ${line}; done; }
}

should_init_db_by_type () {
  INITIALIZED_TYPES="mysql"
  for t in "${INITIALIZED_TYPES}"; do
    [[ $t = $MGOGS_DB_TYPE ]] && return 0
  done
  return 1
}

db_already_initialized () {
  case "${MGOGS_DB_TYPE}" in
    mysql)
      echo "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '${MGOGS_DB_NAME}'" \
        | mysql_exec \
        | grep "${MGOGS_DB_NAME}" 2>&1
      ;;
    *)
      echo "Invalid DB type. DB init not required"
      exit 0
  esac
}

do_init_db () {
  case "${MGOGS_DB_TYPE}" in
    mysql)
      mysql_exec <<-EOSQL
        CREATE DATABASE ${MGOGS_DB_NAME}
          DEFAULT CHARACTER SET utf8mb4
          DEFAULT COLLATE utf8mb4_general_ci;

        CREATE USER '${MGOGS_DB_USER}'@'%'
          IDENTIFIED BY '${MGOGS_DB_PASSWORD}';

        GRANT ALL ON \`${MGOGS_DB_NAME}\`.* TO '${MGOGS_DB_USER}'@'%';
        FLUSH PRIVILEGES;
EOSQL
      ;;
    *)
      echo "Invalid DB type. Exiting ..."
      exit 1
  esac
}

init_db () {
  if should_init_db_by_type; then
    echo "DB type requires initialization."
    if db_already_initialized; then
      echo "Database already exists"
    else
      echo "Initializing DB ..."
      do_init_db
    fi
  fi
}

init_dirs () {
  mkdir -p "${DIR}/../volume/gogs"
  ln -sf `realpath "${DIR}/../volume/gogs/data"` "${DIR}/../data"
}

init_conf () {
  mkdir -p "${DIR}/../custom/conf"
  if [ ! -f "${DIR}/../volume/gogs/app.ini.template" ]; then
    cp "${DIR}/../app.ini.template" "${DIR}/../volume/gogs/app.ini.template"
  fi
  envsubst < "${DIR}/../volume/gogs/app.ini.template" > "${DIR}/../custom/conf/app.ini"
}

init () {
  init_db
  init_dirs
  init_conf
}
