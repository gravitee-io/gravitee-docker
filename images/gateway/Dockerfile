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
FROM graviteeio/java:8
MAINTAINER Gravitee Team <http://gravitee.io>

ARG GRAVITEEIO_VERSION=0

RUN echo 'root:gravitee' | chpasswd
RUN groupadd gravitee && useradd -s /bin/bash -m -g gravitee gravitee
RUN echo 'gravitee:gravitee' |chpasswd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod u+x /usr/local/bin/entrypoint.sh

USER gravitee
WORKDIR /home/gravitee

RUN wget https://bintray.com/artifact/download/gravitee-io/release/${GRAVITEEIO_VERSION}/graviteeio-gateway-${GRAVITEEIO_VERSION}.zip \
    && zip -FFv graviteeio-gateway-${GRAVITEEIO_VERSION}.zip --out graviteeio-gateway-${GRAVITEEIO_VERSION}.fixed.zip \
    && unzip graviteeio-gateway-${GRAVITEEIO_VERSION}.fixed.zip \
    && rm graviteeio-gateway-${GRAVITEEIO_VERSION}.fixed.zip

COPY healthcheck.sh ./healthcheck.sh

ENV GRAVITEEIO_HOME /home/gravitee/graviteeio-gateway-${GRAVITEEIO_VERSION}
WORKDIR ${GRAVITEEIO_HOME}

ENV MONGO_DEFAULT_HOST localhost
ENV MONGO_DEFAULT_PORT 27017
ENV MONGO_HOST localhost
ENV MONGO_PORT 27017
ENV ES_DEFAULT_HOST localhost
ENV ES_DEFAULT_PORT 9300
ENV ES_HOST localhost
ENV ES_PORT 9300
ENV healthcheck false

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
EXPOSE 8082
CMD ["./bin/gravitee"]
