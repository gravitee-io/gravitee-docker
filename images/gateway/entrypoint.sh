#!/bin/bash

setup() {
    
    if (( "true" == "$load_samples" )); then
        echo "Load sample apis"
        rm /home/gravitee/config/gravitee.yml
        cp /home/gravitee/config/local_default_gravitee.yml /home/gravitee/config/gravitee.yml
    fi

    echo "Configure mongodb address from ${MONGO_DEFAULT_HOST}:${MONGO_DEFAULT_PORT} to ${MONGO_HOST}:${MONGO_PORT}"
    sed -i s/"host: ${MONGO_DEFAULT_HOST}"/"host: ${MONGO_HOST}"/ /home/gravitee/config/gravitee.yml
    sed -i s/"port: ${MONGO_DEFAULT_PORT}"/"port: ${MONGO_PORT}"/ /home/gravitee/config/gravitee.yml
}

setup
exec "$@"
