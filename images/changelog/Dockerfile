FROM java:openjdk-8-jdk
MAINTAINER GraviteeSource Team <http://graviteesource.com>

ARG MILESTONE_VERSION=0

RUN apt-get update && \
    apt-get -y install wget && \
        apt-get clean
ENV GROOVY_VERSION=2.4.5
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 \
    GROOVY_HOME=/opt/groovy-${GROOVY_VERSION}

ADD http://dl.bintray.com/groovy/maven/apache-groovy-binary-${GROOVY_VERSION}.zip /tmp/
RUN unzip -d /opt/ /tmp/apache-groovy-binary-${GROOVY_VERSION}.zip \
   && rm /tmp/apache-groovy-binary-${GROOVY_VERSION}.zip

RUN wget --no-cache raw.githubusercontent.com/gravitee-io/jenkins-scripts/master/src/main/groovy/githubChangelogGenerator.groovy

RUN mkdir /data
VOLUME /data
WORKDIR /data

CMD export JAVA_HOME=$JAVA_HOME \
    && export GROOVY_HOME=$GROOVY_HOME \
    && export PATH=$GROOVY_HOME/bin:$JAVA_HOME/bin:$PATH \
    && touch CHANGELOG.adoc \
    && groovy -DMILESTONE_VERSION="$MILESTONE_VERSION" /githubChangelogGenerator.groovy
