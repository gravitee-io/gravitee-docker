FROM debian:stable-slim


ARG RESTIC_VERSION=$RESTIC_VERSION
ARG ORCHESTRATOR_GIT_COMMIT_ID=$ORCHESTRATOR_GIT_COMMIT_ID
ARG GITHUB_ORG=$GITHUB_ORG
ARG OCI_VENDOR=$GITHUB_ORG
# LABEL oci.image.tag=maven:"${MAVEN_VERSION}"-openjdk-"${OPENJDK_VERSION}"
LABEL cicd.restic.version="${RESTIC_VERSION}"
LABEL cicd.orchestrator.git.commit.id="${ORCHESTRATOR_GIT_COMMIT_ID}"
LABEL oci.image.tag="restic-${RESTIC_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
LABEL cicd.github.org="${GITHUB_ORG}"
LABEL vendor="${OCI_VENDOR}"
LABEL maintainer="jean-baptiste.lasselle@graviteesource.com"

# [sha256sum] contains sha256sum utility
# RUN apt-get update -y && apt-get install -y curl wget python3-pip jq
RUN apt-get update -y && apt-get install -y bash curl wget bzip2 coreutils jq unzip tree

# install kubectl latest stable
# https://kubernetes.io/docs/tasks/tools/install-kubectl/
# doxnload binary
RUN mkdir -p /gio/devops/bucket
VOLUME /gio/devops/bucket
VOLUME /root/.restic.cfg
# /root/.restic is a file
# VOLUME /root/.restic
WORKDIR /gio/devops
COPY install-restic.sh /gio/devops
RUN chmod +x ./install-restic.sh && ./install-restic.sh
# ENTRYPOINT [ "/gio/devops/install-restic.sh" ]
CMD [ "/bin/bash" ]
