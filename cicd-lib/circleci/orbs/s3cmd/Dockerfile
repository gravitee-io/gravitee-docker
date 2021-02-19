FROM debian:stable-slim


ARG S3CMD_VERSION=$S3CMD_VERSION
ARG ORCHESTRATOR_GIT_COMMIT_ID=$ORCHESTRATOR_GIT_COMMIT_ID
ARG GITHUB_ORG=$GITHUB_ORG
ARG OCI_VENDOR=$GITHUB_ORG
# LABEL oci.image.tag=maven:"${MAVEN_VERSION}"-openjdk-"${OPENJDK_VERSION}"
LABEL cicd.s3cmd.version="${S3CMD_VERSION}"
LABEL cicd.orchestrator.git.commit.id="${ORCHESTRATOR_GIT_COMMIT_ID}"
LABEL oci.image.tag="s3cmd-${S3CMD_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
LABEL cicd.github.org="${GITHUB_ORG}"
LABEL vendor="${OCI_VENDOR}"
LABEL maintainer="jean-baptiste.lasselle@graviteesource.com"

# [python-pip] package necessary for s3cmd installation
# [python3-pip] package necessary for s3cmd installation  ?
# RUN apt-get update -y && apt-get install -y curl wget python3-pip jq
RUN apt-get update -y && apt-get install -y bash curl wget python-pip python-setuptools jq unzip tree

# install kubectl latest stable
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
# doxnload binary
RUN mkdir -p /gio/devops/bucket
VOLUME /gio/devops/bucket
# /root/.s3cmd is a file
# VOLUME /root/.s3cmd
WORKDIR /gio/devops
COPY install-s3cmd.sh /gio/devops
RUN chmod +x ./install-s3cmd.sh && ./install-s3cmd.sh
# ENTRYPOINT [ "/gio/devops/install-s3cmd.sh" ]
CMD [ "/bin/bash" ]
