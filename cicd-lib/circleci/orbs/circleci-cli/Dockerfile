FROM debian:stable-slim


ARG CCI_CLI_VERSION=$CCI_CLI_VERSION
ARG GIT_COMMIT_ID=$GIT_COMMIT_ID
ARG GITHUB_ORG=$GITHUB_ORG
ARG OCI_VENDOR=$GITHUB_ORG
# LABEL oci.image.tag=maven:"${MAVEN_VERSION}"-openjdk-"${OPENJDK_VERSION}"
LABEL cicd.s3cmd.version="${CCI_CLI_VERSION}"
LABEL cicd.orchestrator.git.commit.id="${GIT_COMMIT_ID}"
LABEL oci.image.tag="s3cmd-${CCI_CLI_VERSION}"
LABEL cicd.github.org="${GITHUB_ORG}"
LABEL vendor="${OCI_VENDOR}"
LABEL maintainer="jean-baptiste.lasselle@graviteesource.com"

# [cut] is in package coreutils see https://packages.debian.org/sid/amd64/coreutils/filelist
RUN apt-get update -y && apt-get install -y bash curl coreutils wget jq unzip tree

# install kubectl latest stable
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
# doxnload binary
RUN mkdir -p /gio/devops/orb
VOLUME /gio/devops/orb
# /root/.s3cmd is a file
# VOLUME /root/.s3cmd
WORKDIR /gio/devops
COPY install-cci-cli.sh /gio/devops
RUN chmod +x ./install-cci-cli.sh && ./install-cci-cli.sh
# ENTRYPOINT [ "/gio/devops/install-cci-cli.sh" ]
CMD [ "/bin/bash" ]
