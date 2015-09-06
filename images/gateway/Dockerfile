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

RUN echo 'root:gravitee' |chpasswd
RUN groupadd gravitee && useradd -s /bin/bash -m -g gravitee gravitee
RUN echo 'gravitee:gravitee' |chpasswd

WORKDIR /home/gravitee
RUN wget http://build.gravitee.io/jenkins/job/gravitee-standalone/lastSuccessfulBuild/artifact/gravitee-standalone-distribution/zip/target/gravitee-standalone-1.0.0-SNAPSHOT.zip && \
	unzip gravitee-standalone-1.0.0-SNAPSHOT.zip && \
    rm gravitee-standalone-1.0.0-SNAPSHOT.zip

RUN mkdir -p /etc/gravitee.io/log/
RUN chown -R gravitee:gravitee /etc/gravitee.io/

RUN sed -i s/"    host: localhost"/"    host: graviteeiodemo_mongodb_1"/ /home/gravitee/config/gravitee.yml

EXPOSE 8082
VOLUME ["/etc/gravitee.io/log"]

CMD ["/home/gravitee/bin/gravitee"]
