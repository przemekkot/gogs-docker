#!/bin/bash
set -e

generate_passwd_file() {
  export USER_ID="${1}"
  export GROUP_ID="${2}"
  envsubst < "/gogs/passwd.template" > "/gogs/passwd"
  export LD_PRELOAD=libnss_wrapper.so
  export NSS_WRAPPER_PASSWD="/gogs/passwd"
  export NSS_WRAPPER_GROUP=/etc/group
}

generate_passwd_file `id -u` `id -g`
exec "$@"
