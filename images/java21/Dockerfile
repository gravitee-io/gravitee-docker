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
FROM eclipse-temurin:21-jre-alpine

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# fontconfig and ttf-dejavu added to support serverside image generation by Java programs
RUN apk -U upgrade \
  && apk add --no-cache fontconfig libretls musl-locales musl-locales-lang ttf-dejavu tzdata zlib openssl libc6-compat curl htop jattach libstdc++ libgcc \
  && rm -rf /var/cache/apk/*

RUN echo Verifying install ... \
  && echo java --version && java --version \
  && echo Complete.

# Define default command.
CMD ["java", "-version"]
