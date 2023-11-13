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
FROM alpine:3.17

ENV JAVA_HOME /opt/java/openjdk
ENV PATH $JAVA_HOME/bin:$PATH

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# fontconfig and ttf-dejavu added to support serverside image generation by Java programs
RUN apk -U upgrade \
  && apk add --no-cache fontconfig libretls musl-locales musl-locales-lang ttf-dejavu tzdata zlib openssl libc6-compat curl htop jattach libstdc++ libgcc curl \
  && rm -rf /var/cache/apk/*


# Linux adoptium image come from: https://github.com/adoptium/temurin17-binaries/releases > "OpenJDK17U-jre_x64_alpine-linux_hotspot"
# bellsoft image come from: https://bell-sw.com/pages/downloads/#jdk-17-lts > "Alpine Linux" > "ARM" > "Standard JRE" > "Tar GZ"
RUN set -eux; \
  ARCH="$(apk --print-arch)"; \
  case "${ARCH}" in \
    amd64|x86_64) \
      ESUM='70e5d108f51ae7c7b2435d063652df058723e303a18b4f72f17f75c5320052d3'; \
      BINARY_URL='https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.9%2B9/OpenJDK17U-jre_x64_alpine-linux_hotspot_17.0.9_9.tar.gz'; \
    ;; \
    aarch64) \
      ESUM='b97223cb87a500e2cfc4e85b0cd7bf62f9267b415e846e4f0a5c91e98cab8dc7'; \
      BINARY_URL='https://download.bell-sw.com/java/17.0.9+11/bellsoft-jdk17.0.9+11-linux-aarch64-musl.tar.gz'; \
    ;; \
    *) \
    echo "Unsupported arch: ${ARCH}"; \
    exit 1; \
    ;; \
  esac; \
  curl -L -o /tmp/openjdk.tar.gz ${BINARY_URL}; \
  echo "${ESUM} */tmp/openjdk.tar.gz" | sha256sum -c -; \
  mkdir -p "$JAVA_HOME"; \
  tar --extract \
      --file /tmp/openjdk.tar.gz \
      --directory "$JAVA_HOME" \
      --strip-components 1 \
      --no-same-owner \
  ; \
  rm /tmp/openjdk.tar.gz;

RUN echo Verifying install ... \
  && echo java --version && java --version \
  && echo Complete.

# Define default command.
CMD ["java", "-version"]
