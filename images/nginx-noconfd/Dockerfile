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

ADD nginx.conf /etc/nginx

RUN mkdir -p /rw.mount/nginx/logs; \
  ln -sf /dev/stdout /var/log/nginx/access.log; \
  ln -sf /dev/stderr /var/log/nginx/error.log; \
  chown -R 101:0 /usr/share/nginx /var/log/nginx /var/cache/nginx /rw.mount /var/run; \
  chmod -R g+w /var/cache/nginx /rw.mount

COPY run.sh /run.sh

CMD ["sh", "/run.sh"]
