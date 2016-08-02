#!/bin/bash

setup() {
    echo "Configure management api url to ${MGMT_API_URL}"
    cat /var/www/html/constants.js.template | \
    sed "s#/management/#${MGMT_API_URL}#g" > /var/www/html/constants.js
}

setup
exec "$@"
