ARG logstash_version
FROM docker.elastic.co/logstash/logstash:${logstash_version}
COPY logstash-codec-gzip_lines-3.0.4.gem /etc/logstash/logstash-codec-gzip_lines-3.0.4.gem
RUN bin/logstash-plugin install --no-verify /etc/logstash/logstash-codec-gzip_lines-3.0.4.gem
