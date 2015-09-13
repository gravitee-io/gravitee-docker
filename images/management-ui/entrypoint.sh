#!/bin/bash

setup() {
    echo "Configure management api url from ${MGMT_API_DEFAULT_HOST}:${MGMT_API_DEFAULT_PORT} to ${MGMT_API_HOST}:${MGMT_API_PORT}"
    sed -i s/"${MGMT_API_DEFAULT_HOST}:${MGMT_API_DEFAULT_PORT}"/"${MGMT_API_HOST}:${MGMT_API_PORT}"/ /var/www/html/scripts/app*.js
}

setup
exec "$@"
