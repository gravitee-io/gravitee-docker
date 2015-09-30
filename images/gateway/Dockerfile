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
FROM graviteeio/java:8u45
MAINTAINER Gravitee Team <http://gravitee.io>

ENV GRAVITEEIO_VERSION	0.1.0-SNAPSHOT

RUN echo 'root:gravitee' |chpasswd
RUN groupadd gravitee && useradd -s /bin/bash -m -g gravitee gravitee
RUN echo 'gravitee:gravitee' |chpasswd

# Download gravitee
WORKDIR /home/gravitee
RUN wget http://build.gravitee.io/jenkins/job/gravitee-standalone/lastSuccessfulBuild/artifact/gravitee-standalone-distribution/zip/target/gravitee-standalone-${GRAVITEEIO_VERSION}.zip && \
    unzip gravitee-standalone-${GRAVITEEIO_VERSION}.zip && \
    rm gravitee-standalone-${GRAVITEEIO_VERSION}.zip && \
    mv gravitee-standalone-${GRAVITEEIO_VERSION}/* . && \
    rmdir gravitee-standalone-${GRAVITEEIO_VERSION}
    
RUN mkdir -p /etc/gravitee.io/log/
RUN chown -R gravitee:gravitee /etc/gravitee.io/

# Download plugins
WORKDIR /home/gravitee/plugins
RUN wget http://build.gravitee.io/jenkins/job/gravitee-reporter-file/lastSuccessfulBuild/artifact/target/gravitee-reporter-file-${GRAVITEEIO_VERSION}.zip
RUN wget http://build.gravitee.io/jenkins/job/gravitee-reporter-es/lastSuccessfulBuild/artifact/target/gravitee-reporter-es-${GRAVITEEIO_VERSION}.zip

# Add default API
WORKDIR /home/gravitee
RUN mkdir -p apis
COPY weather.json apis/weather.json
COPY local_default_gravitee.yml config/local_default_gravitee.yml

ENV MONGO_DEFAULT_HOST localhost
ENV MONGO_DEFAULT_PORT 27017
ENV MONGO_HOST localhost
ENV MONGO_PORT 27017
ENV ES_DEFAULT_HOST localhost
ENV ES_HOST localhost
ENV load_samples false
ENV check_links false

COPY healthcheck.sh /healthcheck.sh
RUN chmod u+x /healthcheck.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8082
VOLUME ["/etc/gravitee.io/log"]

CMD ["/home/gravitee/bin/gravitee"]
