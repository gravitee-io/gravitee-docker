#!/bin/bash
. /healthcheck.sh
setup() {
    echo "Configure mongodb address from ${MONGO_DEFAULT_HOST}:${MONGO_DEFAULT_PORT} to ${MONGO_HOST}:${MONGO_PORT}"
    sed -i s/"host: ${MONGO_DEFAULT_HOST}"/"host: ${MONGO_HOST}"/ /home/gravitee/config/gravitee.yml
    sed -i s/"port: ${MONGO_DEFAULT_PORT}"/"port: ${MONGO_PORT}"/ /home/gravitee/config/gravitee.yml
}

if (( "true" == "$check_links" )); then
    healthcheck $MONGO_HOST $MONGO_PORT 5
fi
setup
exec "$@"
