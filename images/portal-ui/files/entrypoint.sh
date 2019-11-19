#!/bin/bash

setup() {
    echo "Configure portal api url to ${PORTAL_API_URL}"
    file_path=$(find /var/www/html -type f -name "main-es2015*.js" -exec echo "{}" +)
    cat /var/www/html/main.js.template | sed "s#/portal/DEFAULT#${PORTAL_API_URL}#g" > ${file_path}
}

setup
exec "$@"
