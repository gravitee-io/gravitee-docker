ARG logstash_version
FROM docker.elastic.co/logstash/logstash:${logstash_version}
RUN bin/logstash-plugin install logstash-codec-gzip_lines