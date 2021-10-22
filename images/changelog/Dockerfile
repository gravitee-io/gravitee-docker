FROM groovy
LABEL maintainer="contact@graviteesource.com"

USER root

ARG MILESTONE_VERSION=0

RUN apt-get update && apt-get -y upgrade && \
    apt-get -y install wget && \
        apt-get clean
ENV GROOVY_VERSION=3.0.9

ENV JAVA_HOME=/opt/java/openjdk \
    GROOVY_HOME=/opt/groovy-${GROOVY_VERSION}

ADD https://dl.bintray.com/groovy/maven/apache-groovy-binary-${GROOVY_VERSION}.zip /tmp/
RUN unzip -d /opt/ /tmp/apache-groovy-binary-${GROOVY_VERSION}.zip \
   && rm /tmp/apache-groovy-binary-${GROOVY_VERSION}.zip

RUN wget --no-cache raw.githubusercontent.com/gravitee-io/jenkins-scripts/master/src/main/groovy/githubChangelogGenerator.groovy -P /tmp

RUN mkdir /data
VOLUME /data
WORKDIR /data

CMD export JAVA_HOME=$JAVA_HOME \
    && export GROOVY_HOME=$GROOVY_HOME \
    && export PATH=$GROOVY_HOME/bin:$JAVA_HOME/bin:$PATH \
    && touch CHANGELOG.adoc \
    && groovy -DMILESTONE_VERSION="$MILESTONE_VERSION" /tmp/githubChangelogGenerator.groovy
