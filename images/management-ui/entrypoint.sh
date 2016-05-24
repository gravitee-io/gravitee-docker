#!/bin/bash

setup() {
    echo "Configure management api url to ${MGMT_API_URL}"
    sed -i s/"'\/management\/'"/"'${MGMT_API_URL}'"/ /var/www/html/constants.js
}

setup
exec "$@"
