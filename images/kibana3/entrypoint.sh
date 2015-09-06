#!/bin/bash

readonly MAX_RETRIES=10
readonly SLEEP_IN_SECONDS=2
readonly DASHBOARD_ADDRESS=http://graviteeiodemo_elasticsearch_1:9200/kibana-int/dashboard/Gravitee

load_dashboard() {
    for (( i=1; i<=$MAX_RETRIES; i++ )); do
        echo "Is ElasticSearch running ? $i/$MAX_RETRIES"

        STARTED=$(curl -sf $DASHBOARD_ADDRESS | grep -c Gravitee)
        if (( $STARTED == 1 )); then
            DASHBOARD_UNKNOWN=$(curl -s -XGET ${DASHBOARD_ADDRESS} | grep -c '"found":true')
            if (( $DASHBOARD_UNKNOWN == 1 )); then
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

load_dashboard
exec "$@"
