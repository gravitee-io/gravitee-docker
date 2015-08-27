#!/bin/bash
set -e

/etc/init.d/elasticsearch start
sleep 10
curl -XPOST  http://localhost:9200/kibana-int/dashboard/Gravitee  -H "Content-Type: application/json" --data-binary "@/tmp/gravitee-dashboard.json"

exec "$@"
