#-------------------------------------------------------------------------------
# Copyright (C) 2015-2022 The Gravitee team (http://gravitee.io)
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#            http://www.apache.org/licenses/LICENSE-2.0
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#-------------------------------------------------------------------------------
ARG  NGINX_VERSION=1.25
FROM nginx:${NGINX_VERSION}-alpine
LABEL maintainer="contact@graviteesource.com"

ENV WWW_TARGET /usr/share/nginx/html
ENV HTTP_PORT 8080
ENV HTTPS_PORT 8443
ENV SERVER_NAME _

RUN apk -U upgrade \
  && apk add --update --no-cache wget curl \
  && rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log; \
  ln -sf /dev/stderr /var/log/nginx/error.log; \
  sed -i '/user  nginx;/d' /etc/nginx/nginx.conf; \
  sed -i 's,/var/run/nginx.pid,/tmp/nginx.pid,' /etc/nginx/nginx.conf; \
  sed -i "/^http {/a \    proxy_temp_path /tmp/proxy_temp;\n    client_body_temp_path /tmp/client_temp;\n    fastcgi_temp_path /tmp/fastcgi_temp;\n    uwsgi_temp_path /tmp/uwsgi_temp;\n    scgi_temp_path /tmp/scgi_temp;\n" /etc/nginx/nginx.conf; \
  chown -R 101:0 /usr/share/nginx /var/log/nginx /var/cache/nginx /etc/nginx /var/run; \
  chmod -R g+w /var/cache/nginx; \
  chmod -R g+w /etc/nginx; \
  apk del wget;

COPY run.sh /run.sh

CMD ["sh", "/run.sh"]
