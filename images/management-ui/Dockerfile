#-------------------------------------------------------------------------------
# Copyright (C) 2015 The Gravitee team (http://gravitee.io)
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
FROM alpine:3.7 as build

ARG GRAVITEEIO_VERSION=0
ARG CONFD_VERSION=0.15.0

RUN apk --update add zip unzip bash wget

# download Gravitee.io
RUN wget -O /tmp/graviteeio-full.zip https://download.gravitee.io/graviteeio-apim/distributions/graviteeio-full-${GRAVITEEIO_VERSION}.zip --no-check-certificate
RUN unzip /tmp/graviteeio-full.zip -d /tmp/
RUN mkdir -p /src/app/graviteeio-management-ui
RUN mv /tmp/graviteeio-full-${GRAVITEEIO_VERSION}/graviteeio-management-ui*/* /src/app/graviteeio-management-ui/

# download confd
RUN mkdir -p /src/app/confd
RUN wget -O /src/app/confd/confd https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 --no-check-certificate

#-------------------------------------------------------------------------------
# CREATE IMAGE
#-------------------------------------------------------------------------------
FROM nginx:1.12-alpine

ARG GRAVITEEIO_VERSION=0
LABEL maintainer="Gravitee Team <http://gravitee.io>" \
      version="${GRAVITEEIO_VERSION}"

ENV GRAVITEEIO_HOME /var/www/html/
ENV CONFD_BACKEND consul
ENV CONFD_NODE 127.0.0.1:8500
ENV CONFD_PREFIX /graviteeio/apim/webui

# set workdir
RUN mkdir -p ${GRAVITEEIO_HOME}
WORKDIR ${GRAVITEEIO_HOME}

# copy webui content
COPY --from=build /src/app/graviteeio-management-ui/ ./

# nginx
COPY ./files/nginx.conf /etc/nginx/conf.d/default.conf

# confd
COPY --from=build /src/app/confd/confd /usr/local/bin/
RUN chmod u+x /usr/local/bin/confd
RUN mkdir -p /etc/confd/{conf.d,templates}
COPY ./files/confd/*.toml /etc/confd/conf.d/
COPY ./files/confd/*.tmpl /etc/confd/templates/

COPY ./files/entrypoint.sh /usr/local/bin/
RUN chmod u+x /usr/local/bin/entrypoint.sh

EXPOSE 80 443
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
