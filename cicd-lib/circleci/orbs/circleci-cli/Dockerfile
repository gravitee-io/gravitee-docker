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
RUN apt-get update -y && apt-get install -y bash curl coreutils git wget jq unzip tree gnupg build-essential openssh-client ca-certificates

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ For Docker installation
# https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/11.0.3-jdk-stretch/Dockerfile
RUN apt-get update \
  && mkdir -p /usr/share/man/man1 \
  && apt-get install -y \
    git mercurial xvfb apt \
    locales sudo openssh-client ca-certificates tar gzip parallel \
    net-tools netcat unzip zip bzip2 gnupg curl wget make
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# --- NON ROOT USER
ARG NON_ROOT_USER_UID=1000
ENV NON_ROOT_USER_UID=$NON_ROOT_USER_UID
ARG NON_ROOT_USER_GID=1000
ENV NON_ROOT_USER_GID=$NON_ROOT_USER_GID

ARG NON_ROOT_USER_NAME=circleci
ENV NON_ROOT_USER_NAME=$NON_ROOT_USER_NAME
ARG NON_ROOT_USER_GRP=circleci
ENV NON_ROOT_USER_GRP=$NON_ROOT_USER_GRP

LABEL oci.image.nonroot.user.name=$NON_ROOT_USER_NAME
LABEL oci.image.nonroot.user.group=$NON_ROOT_USER_GRP
LABEL oci.image.nonroot.user.uid=$NON_ROOT_USER_UID
LABEL oci.image.nonroot.user.gid=$NON_ROOT_USER_GID


RUN groupadd -g $NON_ROOT_USER_GID $NON_ROOT_USER_GRP
RUN useradd -g $NON_ROOT_USER_GRP -u $NON_ROOT_USER_UID -m $NON_ROOT_USER_NAME

RUN ls -allh /home/$NON_ROOT_USER_NAME


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# see https://github.com/CircleCI-Public/circleci-dockerfiles/blob/master/openjdk/images/11.0.3-jdk-stretch/Dockerfile
# Install Docker

# Docker.com returns the URL of the latest binary when you hit a directory listing
# We curl this URL and `grep` the version out.
# The output looks like this:

#>    # To install, run the following commands as root:
#>    curl -fsSLO https://download.docker.com/linux/static/stable/x86_64/docker-17.05.0-ce.tgz && tar --strip-components=1 -xvzf docker-17.05.0-ce.tgz -C /usr/local/bin
#>
#>    # Then start docker in daemon mode:
#>    /usr/local/bin/dockerd

RUN set -ex \
  && export DOCKER_VERSION=$(curl --silent --fail --retry 3 https://download.docker.com/linux/static/stable/x86_64/ | grep -o -e 'docker-[.0-9]*\.tgz' | sort -r | head -n 1) \
  && echo "installed docker version is DOCKER_VERSION=[${DOCKER_VERSION}]" \
  && DOCKER_URL="https://download.docker.com/linux/static/stable/x86_64/${DOCKER_VERSION}" \
  && echo Docker URL: $DOCKER_URL \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/docker.tgz "${DOCKER_URL}" \
  && ls -lha /tmp/docker.tgz \
  && tar -xz -C /tmp -f /tmp/docker.tgz \
  && mv /tmp/docker/* /usr/bin \
  && rm -rf /tmp/docker /tmp/docker.tgz \
  && which docker \
  && (docker version || true)

# docker compose
RUN COMPOSE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/docker-compose-latest" \
  && curl --silent --show-error --location --fail --retry 3 --output /usr/bin/docker-compose $COMPOSE_URL \
  && chmod +x /usr/bin/docker-compose \
  && docker-compose version

# install dockerize
RUN DOCKERIZE_URL="https://circle-downloads.s3.amazonaws.com/circleci-images/cache/linux-amd64/dockerize-latest.tar.gz" \
  && curl --silent --show-error --location --fail --retry 3 --output /tmp/dockerize-linux-amd64.tar.gz $DOCKERIZE_URL \
  && tar -C /usr/local/bin -xzvf /tmp/dockerize-linux-amd64.tar.gz \
  && rm -rf /tmp/dockerize-linux-amd64.tar.gz \
  && dockerize --version

# RUN groupadd --gid 3434 circleci \
#   && useradd --uid 3434 --gid circleci --shell /bin/bash --create-home circleci \
#   && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
#   && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep
COPY etc.sudoers .
RUN mkdir -p /etc/ && cat ./etc.sudoers > /etc/sudoers && rm ./etc.sudoers
RUN mkdir -p /etc/sudoers.d/ && mkdir -p /root \
  && groupadd docker \
  && echo 'docker ALL=NOPASSWD: /usr/bin/docker' >> /etc/sudoers.d/40-docker \
  && echo 'circleci ALL=NOPASSWD: ALL' >> /etc/sudoers.d/50-circleci \
  && echo 'Defaults    env_keep += "DEBIAN_FRONTEND"' >> /etc/sudoers.d/env_keep \
  && usermod -aG docker $NON_ROOT_USER_NAME
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


RUN mkdir -p /gio/devops/orb
RUN chown $NON_ROOT_USER_NAME:$NON_ROOT_USER_GRP /home/$NON_ROOT_USER_NAME/.secrets

RUN echo "whoami = [$(whoami)]"
USER $NON_ROOT_USER_NAME
RUN echo "whoami = [$(whoami)]"

VOLUME /gio/devops/orb
# /root/.s3cmd is a file
# VOLUME /root/.s3cmd
WORKDIR /gio/devops
COPY install-cci-cli.sh /gio/devops
RUN chmod +x ./install-cci-cli.sh && ./install-cci-cli.sh
# ENTRYPOINT [ "/gio/devops/install-cci-cli.sh" ]
CMD [ "/bin/bash" ]
