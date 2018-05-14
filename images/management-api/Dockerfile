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
ARG ENVCONSUL_VERSION=0.7.3

RUN apk --update add zip unzip bash wget

# download Gravitee.io
RUN wget -O /tmp/graviteeio-full.zip https://download.gravitee.io/graviteeio-apim/distributions/graviteeio-full-${GRAVITEEIO_VERSION}.zip --no-check-certificate
RUN unzip /tmp/graviteeio-full.zip -d /tmp/
RUN mkdir -p /src/app/graviteeio-management-api
RUN mv /tmp/graviteeio-full-${GRAVITEEIO_VERSION}/graviteeio-management-api*/* /src/app/graviteeio-management-api/

# download envconsul
RUN wget -O /tmp/envconsul.zip https://releases.hashicorp.com/envconsul/${ENVCONSUL_VERSION}/envconsul_${ENVCONSUL_VERSION}_linux_amd64.zip --no-check-certificate
RUN mkdir -p /src/app/envconsul
RUN unzip /tmp/envconsul.zip -d /src/app/envconsul/

#-------------------------------------------------------------------------------
# CREATE IMAGE
#-------------------------------------------------------------------------------
FROM graviteeio/java:8

LABEL maintainer="Gravitee Team <http://gravitee.io>"

ENV GRAVITEEIO_HOME /opt/graviteeio-management-api
ENV CONSUL_ADDR 127.0.0.1:8500
ENV CONSUL_PREFIX graviteeio/apim/managementapi

# set workdir
RUN mkdir -p ${GRAVITEEIO_HOME}
WORKDIR ${GRAVITEEIO_HOME}

# copy management-api content
COPY --from=build /src/app/graviteeio-management-api/ ./

# envconsul
COPY --from=build /src/app/envconsul/envconsul /usr/local/bin/
RUN chmod u+x /usr/local/bin/envconsul

EXPOSE 8083
ENTRYPOINT envconsul \
           -consul-addr=${CONSUL_ADDR} \
           -prefix ${CONSUL_PREFIX} \
           -once \
           ./bin/gravitee
