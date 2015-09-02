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

COPY mongodb-org-3.0.repo /etc/yum.repos.d/mongodb-org-3.0.repo

RUN yum -y update && \
    yum install -y mongodb-org && \
    yum clean all && \
    rm -rf /tmp/* /var/tmp/*

EXPOSE 27017
VOLUME ["/var/log/mongodb", "/var/lib/mongo"]

CMD ["/usr/bin/mongod", "--dbpath", "/var/lib/mongo", "--bind_ip", "127.0.0.1", "--port", "27017", "--logpath", "/var/log/mongodb/mongod.log", "--logappend"]
