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
