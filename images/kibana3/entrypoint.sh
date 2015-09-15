#!/bin/bash

readonly MAX_RETRIES=20
readonly SLEEP_IN_SECONDS=3
readonly DASHBOARD_ADDRESS=http://elasticsearch:9200/kibana-int/dashboard/Gravitee

. /healthcheck.sh

setup() {
    # setup ES url
    sed -i "s|\"http:\/\/\"+window.location.hostname+\":9200\"|\"http:\/\/$ES_HOST:$ES_PORT\"|" /var/www/html/config.js

    # load Dashboard
    for (( i=1; i<=$MAX_RETRIES; i++ )); do
        echo "Is ElasticSearch running ? $i/$MAX_RETRIES"

        STARTED=$(curl -s $DASHBOARD_ADDRESS | grep -c kibana-int)
        if (( $STARTED == 1 )); then
            DASHBOARD_UNKNOWN=$(curl -s -XGET ${DASHBOARD_ADDRESS} | grep -c '"found":true')
            if (( $DASHBOARD_UNKNOWN == 0 )); then
                echo "Kibana Dashboard doesn't exist."
                curl -XPOST  ${DASHBOARD_ADDRESS}  -H "Content-Type: application/json" --data-binary "@/tmp/gravitee-dashboard.json"
                echo
                echo "Dashboard loaded."
            else
                echo "Kibana Dashboard is already imported."
            fi
            return 0
        fi
        sleep $SLEEP_IN_SECONDS
    done
    return 1
}

if (( "true" == "$check_links" )); then
    healthcheck $ES_HOST 9200 5
fi
setup
exec "$@"
