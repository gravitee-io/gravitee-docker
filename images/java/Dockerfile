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
    yum install -y \
        wget \
        nc \
        zip \
        unzip && \
    yum clean all && \
    rm -rf /tmp/* /var/tmp/*

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u91-b14/jre-8u91-linux-x64.rpm"
RUN rpm -Uvh jre-8u91-linux-x64.rpm && rm -f jre-8u91-linux-x64.rpm
ENV JAVA_HOME /usr/java/latest
