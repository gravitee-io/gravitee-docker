#!/bin/bash
. ~/healthcheck.sh
setup() {

    echo "Configure elasticsearch address from ${ES_DEFAULT_HOST}:${ES_DEFAULT_PORT} to ${_HOST}:${_PORT}"
    sed -i 162s/"host: ${ES_DEFAULT_HOST}"/"host: ${ES_HOST}"/ ${GRAVITEEIO_HOME}/config/gravitee.yml
    sed -i 163s/"port: ${ES_DEFAULT_PORT}"/"port: ${ES_PORT}"/ ${GRAVITEEIO_HOME}/config/gravitee.yml

    echo "Configure mongodb address from ${MONGO_DEFAULT_HOST}:${MONGO_DEFAULT_PORT} to ${MONGO_HOST}:${MONGO_PORT}"
    sed -i 159s/"host: ${MONGO_DEFAULT_HOST}"/"host: ${MONGO_HOST}"/ ${GRAVITEEIO_HOME}/config/gravitee.yml
    sed -i 160s/"port: ${MONGO_DEFAULT_PORT}"/"port: ${MONGO_PORT}"/ ${GRAVITEEIO_HOME}/config/gravitee.yml
}

if [[ "true" == "$check_links" ]]; then
    healthcheck $ES_HOST $ES_PORT 5
    healthcheck $MONGO_HOST $MONGO_PORT 5
fi
setup
exec "$@"
