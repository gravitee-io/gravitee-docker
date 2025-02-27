#!/bin/sh
#
# Copyright (C) 2015-2022 The Gravitee team (http://gravitee.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# prepare RW allowed dirs
mkdir -p /rw.mount/nginx /rw.mount/www/

# copy app to RW allowed directory
cp -r /usr/share/nginx/html/* /rw.mount/www/

# generate configs
if [ -f "/rw.mount/www/constants.json" ]; then
    envsubst < /rw.mount/www/constants.json > /rw.mount/www/constants.json.tmp
    mv /rw.mount/www/constants.json.tmp /rw.mount/www/constants.json
fi

if [ -f "/rw.mount/www/assets/config.json" ]; then
    envsubst < /rw.mount/www/assets/config.json > /rw.mount/www/assets/config.json.tmp
    mv /rw.mount/www/assets/config.json.tmp /rw.mount/www/assets/config.json
fi

envsubst '\$HTTP_PORT \$HTTPS_PORT \$SERVER_NAME \$CONSOLE_BASE_HREF \$ALLOWED_FRAME_ANCESTOR_URLS \$PORTAL_BASE_HREF \$MGMT_BASE_HREF' < /etc/nginx/conf.d/default.conf > /rw.mount/nginx/default.conf.tmp
if [ "$FRAME_PROTECTION_ENABLED" = "false" ]; then
   grep -v "Content-Security-Policy" /rw.mount/nginx/default.conf.tmp > /rw.mount/nginx/defaultWithoutProtection.conf.tmp
   mv /rw.mount/nginx/defaultWithoutProtection.conf.tmp /rw.mount/nginx/default.conf.tmp
fi
if [ "$IPV4_ONLY" = "true" ]; then
   grep -v "# feature-ipv6" /rw.mount/nginx/default.conf.tmp > /rw.mount/nginx/defaultWithoutIPv6.conf.tmp
   mv /rw.mount/nginx/defaultWithoutIPv6.conf.tmp /rw.mount/nginx/default.conf.tmp
fi
mv /rw.mount/nginx/default.conf.tmp /rw.mount/nginx/default.conf

# start nginx foreground
exec /usr/sbin/nginx -g 'daemon off;'
