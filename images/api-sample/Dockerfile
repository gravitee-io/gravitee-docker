FROM centos:6
MAINTAINER Gravitee Team <http://gravitee.io>

RUN yum -y update && \
    yum clean all && \
    yum install -y \
        wget \
        unzip \
        httpd

RUN rm -rf /var/www/html/*

RUN echo "Hello world!" >> /var/www/html/sampleapi.json

EXPOSE 80

CMD /etc/init.d/httpd start && tail -f /var/log/httpd/access_log
