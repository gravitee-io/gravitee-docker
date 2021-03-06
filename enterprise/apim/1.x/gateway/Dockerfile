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
FROM alpine as builder
LABEL maintainer="contact@graviteesource.com"

ARG GRAVITEEIO_VERSION=0
ARG GRAVITEEIO_AE_VERSION=1.2.2
ARG GRAVITEEIO_EE_VERSION=1.1.0
ENV GRAVITEEIO_HOME /opt/graviteeio-gateway

RUN apk --no-cache add zip unzip wget

RUN wget https://download.gravitee.io/graviteeio-apim/distributions/graviteeio-full-${GRAVITEEIO_VERSION}.zip --no-check-certificate -P /tmp/ \
    && unzip /tmp/graviteeio-full-${GRAVITEEIO_VERSION}.zip -d /tmp/ \
    && mv /tmp/graviteeio-full-${GRAVITEEIO_VERSION}/graviteeio-gateway* ${GRAVITEEIO_HOME} \
    && rm -rf /tmp/*

# Prepare license directory
RUN mkdir ${GRAVITEEIO_HOME}/license

# Add specific enterprise libraries and plugins
RUN wget https://download.gravitee.io/graviteeio-ee/license/gravitee-license-node-enterprise-${GRAVITEEIO_EE_VERSION}.jar --no-check-certificate -P ${GRAVITEEIO_HOME}/lib
RUN wget https://download.gravitee.io/graviteeio-ae/plugins/connectors/gravitee-ae-connectors-ws/gravitee-ae-connectors-ws-${GRAVITEEIO_AE_VERSION}.zip --no-check-certificate -P ${GRAVITEEIO_HOME}/plugins

FROM graviteeio/java:8
MAINTAINER GraviteeSource Team <https://gravitee.io>

ENV GRAVITEEIO_HOME /opt/graviteeio-gateway

COPY --from=builder ${GRAVITEEIO_HOME} ${GRAVITEEIO_HOME}

RUN chgrp -R 0 ${GRAVITEEIO_HOME} && \
    chmod -R g=u ${GRAVITEEIO_HOME}

WORKDIR ${GRAVITEEIO_HOME}

EXPOSE 8082
CMD ["./bin/gravitee"]
