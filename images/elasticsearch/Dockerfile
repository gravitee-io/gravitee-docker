FROM centos:6
MAINTAINER Gravitee Team <http://gravitee.io>

RUN yum -y update && \
    yum clean all && \
    yum install -y \
        wget \
        unzip

RUN wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jre-8u45-linux-x64.rpm"
RUN rpm -Uvh jre-8u45-linux-x64.rpm && rm -f jre-8u45-linux-x64.rpm
ENV JAVA_HOME /usr/java/latest

RUN rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
COPY elasticsearch.repo /etc/yum.repos.d/elasticsearch.repo
RUN yum install -y elasticsearch
RUN touch /var/log/elasticsearch/elasticsearch.log
RUN chown elasticsearch:elasticsearch /var/log/elasticsearch/elasticsearch.log


RUN echo 'http.cors.enabled: true' >> /etc/elasticsearch/elasticsearch.yml
RUN echo 'http.cors.allow-origin: "*"' >> /etc/elasticsearch/elasticsearch.yml

RUN /usr/share/elasticsearch/bin/plugin --install lmenezes/elasticsearch-kopf
RUN /usr/share/elasticsearch/bin/plugin --install royrusso/elasticsearch-HQ
RUN /usr/share/elasticsearch/bin/plugin --install lukas-vlcek/bigdesk
RUN /usr/share/elasticsearch/bin/plugin --install mobz/elasticsearch-head

EXPOSE 9200 9300

COPY gravitee-dashboard.json /tmp/gravitee-dashboard.json
COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD /etc/init.d/elasticsearch start && tail -F /var/log/elasticsearch/elasticsearch.log
