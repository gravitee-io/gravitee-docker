FROM centos:6
MAINTAINER Gravitee Team <http://gravitee.io>

COPY mongodb-org-3.0.repo /etc/yum.repos.d/mongodb-org-3.0.repo

RUN yum -y update && \
    yum install -y mongodb-org && \
    yum clean all && \
    rm -rf /tmp/* /var/tmp/*

EXPOSE 27017
VOLUME ["/var/log/mongodb/", "/var/lib/mongo"]

USER mongod
CMD ["/usr/bin/mongod", "--dbpath", "/var/lib/mongo", "--bind_ip", "127.0.0.1", "--port", "27017", "--logpath", "/var/log/mongodb/mongod.log", "--logappend"]
