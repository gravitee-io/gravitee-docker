#-------------------------------------------------------------------------------
# Copyright (C) 2015-2022 The Gravitee team (http://gravitee.io)
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
FROM eclipse-temurin:17-jre-alpine
LABEL maintainer="contact@graviteesource.com"

RUN apk -U upgrade && apk add --no-cache openssl libc6-compat curl htop jattach \
    && rm -rf /var/cache/apk/*

# Define default command.
CMD ["java", "-version"]
