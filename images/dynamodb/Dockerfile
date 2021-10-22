#
# Copyright (C) 2015 The Gravitee team (http://gravitee.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
FROM eclipse-temurin:11-jre-focal
LABEL maintainer="contact@graviteesource.com"

WORKDIR /opt/dynamodb

RUN apk add --update openssl
RUN wget -O /opt/dynamodb/dynamodb_local_latest.tar.gz https://s3.eu-central-1.amazonaws.com/dynamodb-local-frankfurt/dynamodb_local_latest.tar.gz \
    && tar xfz /opt/dynamodb/dynamodb_local_latest.tar.gz \
    && rm -f /opt/dynamodb/dynamodb_local_latest.tar.gz

VOLUME ["/var/lib/dynamodb"]

EXPOSE 8000

CMD ["java", "-Djava.library.path=./DynamoDBLocal_lib", "-jar", "DynamoDBLocal.jar", "-dbPath", "/var/lib/dynamodb", "-optimizeDbBeforeStartup", "-port", "8000"]