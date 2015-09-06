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

COPY elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
RUN yum install -y elasticsearch && \
    yum clean all && \
    rm -rf /tmp/* /var/tmp/*

RUN echo 'http.cors.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
RUN echo 'http.cors.allow-origin: "*"' >> /etc/elasticsearch/elasticsearch.yml

RUN /usr/share/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf
RUN /usr/share/elasticsearch/bin/plugin --install royrusso/elasticsearch-HQ
RUN /usr/share/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
RUN /usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head

EXPOSE 9200 9300
VOLUME ["/var/log/elasticsearch", "/var/lib/elasticsearch"]

CMD ["/usr/share/elasticsearch/bin/elasticsearch", \
    "-Des.default.path.home=/usr/share/elasticsearch", \
    "-Des.default.path.logs=/var/log/elasticsearch", \
    "-Des.default.path.data=/var/lib/elasticsearch", \
    "-Des.default.path.work=/tmp/elasticsearch", \
    "-Des.default.path.conf=/etc/elasticsearch"]
