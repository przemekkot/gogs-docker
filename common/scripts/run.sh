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
source "${DIR}/init.sh"

contains () {
  for s in $1; do
	  [[ $s = $2 ]] && return 1
  done
  return 0
}

not_contains () {
  contains "${1}" "${2}" && return 0 && return 1
}

# Validate args
VALID_DB_TYPES="mysql postgres sqlite3"
DEFAULT_DB_TYPE="sqlite3"
export MGOGS_DB_TYPE=${GOGS_DB_TYPE:-$DEFAULT_DB_TYPE}
if not_contains "${VALID_DB_TYPES}" "${GOGS_DB_TYPE}"; then
	export MGOGS_DB_TYPE="${DEFAULT_DB_TYPE}"
fi

DEFAULT_DB_HOST="127.0.0.1:3306"
export MGOGS_DB_HOST="${GOGS_DB_HOST:-$DEFAULT_DB_HOST}"

DEFAULT_DB_NAME="gogs"
export MGOGS_DB_NAME="${GOGS_DB_NAME:-$DEFAULT_DB_NAME}"

DEFAULT_DB_USER="user"
export MGOGS_DB_USER="${GOGS_DB_USER:-$DEFAULT_DB_USER}"

DEFAULT_DB_PASSWORD="test"
export MGOGS_DB_PASSWORD="${GOGS_DB_PASSWORD:-$DEFAULT_DB_PASSWORD}"

export MGOGS_DB_ROOT_PASSWORD="${GOGS_DB_ROOT_PASSWORD}"

export MGOGS_SECRET_KEY="${GOGS_SECRET_KEY:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)}"

init

/gogs/gogs web
