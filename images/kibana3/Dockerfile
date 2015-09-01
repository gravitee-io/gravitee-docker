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
FROM centos:6
MAINTAINER Gravitee Team <http://gravitee.io>

RUN yum -y update && \
    yum clean all && \
    yum install -y \
        wget \
        unzip \
        httpd

RUN wget --no-cookies https://download.elastic.co/kibana/kibana/kibana-3.1.2.zip

RUN rm -rf /var/www/html/*               && \
    unzip kibana-3.1.2.zip -d /tmp       && \
    mv /tmp/kibana-3.1.2/* /var/www/html && \
    rm -f kibana-3.1.2.zip               && \
    rm -rf /tmp/kibana-3.1.2

RUN sed -i s/window\.location\.hostname/\"localhost\"/ /var/www/html/config.js

EXPOSE 80

CMD /etc/init.d/httpd start && tail -f /var/log/httpd/access_log
