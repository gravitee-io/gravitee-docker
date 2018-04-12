#!/bin/sh
echo "CONFD_BACKEND : ${CONFD_BACKEND}"
echo "CONFD_NODE    : ${CONFD_NODE}"
echo "CONFD_PREFIX  : ${CONFD_PREFIX}"

if [ ! -z $CONFD_NODE ]
then
    mv /var/www/html/constants.json /constants.json.ori
    if [ ! -z $CONFD_NODE ]
    then
        confd -onetime -backend ${CONFD_BACKEND} -node ${CONFD_NODE} -prefix="${CONFD_PREFIX}" -log-level="debug"
    else
        confd -onetime -backend ${CONFD_BACKEND} -node ${CONFD_NODE} -log-level="debug"
    fi
fi
echo "Gravitee.io APIM Webui is ready."
exec "$@"
