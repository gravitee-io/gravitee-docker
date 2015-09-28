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

WORKDIR /home/gravitee
RUN wget http://build.gravitee.io/jenkins/job/gravitee-management-rest-api/lastSuccessfulBuild/artifact/standalone/distribution/zip/target/gravitee-management-standalone-${GRAVITEEIO_VERSION}.zip && \
	unzip gravitee-management-standalone-${GRAVITEEIO_VERSION}.zip && \
    rm gravitee-management-standalone-${GRAVITEEIO_VERSION}.zip

ENV MONGO_DEFAULT_HOST localhost
ENV MONGO_DEFAULT_PORT 27017
ENV MONGO_HOST localhost
ENV MONGO_PORT 27017
ENV check_links false

COPY healthcheck.sh /healthcheck.sh
RUN chmod u+x /healthcheck.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8082
VOLUME ["/home/gravitee/log"]

CMD ["/home/gravitee/bin/gravitee"]
