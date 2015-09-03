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
FROM graviteeio/httpd:latest
MAINTAINER Gravitee Team <http://gravitee.io>

RUN wget --no-cookies  http://build.gravitee.io/jenkins/job/gravitee-management-webui/lastSuccessfulBuild/artifact/target/gravitee-management-webui-1.0.0-SNAPSHOT-bin.zip && \
    unzip gravitee-management-webui-1.0.0-SNAPSHOT-bin.zip -d /tmp       && \
    mv /tmp/gravitee-management-webui-1.0.0-SNAPSHOT/* /var/www/html    && \
    rm -f gravitee-management-webui-1.0.0-SNAPSHOT-bin.zip               && \
    rm -rf /tmp/gravitee-management-webui-1.0.0-SNAPSHOT

CMD ["/usr/sbin/httpd", "-DFOREGROUND"]
