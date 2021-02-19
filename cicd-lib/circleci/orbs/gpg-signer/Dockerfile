ARG DEBIAN_OCI_TAG=$DEBIAN_OCI_TAG
FROM debian:${DEBIAN_OCI_TAG}

RUN apt-get update -y && apt-get install -y gnupg

ARG GITHUB_ORG=unspecified
ARG OCI_VENDOR=$GITHUB_ORG
# LABEL oci.image.tag=maven:"${MAVEN_VERSION}"-openjdk-"${OPENJDK_VERSION}"

ARG GPG_VERSION=2.2.23
LABEL oci.image.tag="${DEBIAN_OCI_TAG}-gpg-${GPG_VERSION}"
LABEL gpg.version=$GPG_VERSION
LABEL cicd.github.org="${GITHUB_ORG}"
LABEL vendor="${OCI_VENDOR}"
LABEL maintainer="jean-baptiste.lasselle@graviteesource.com"


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


# --- #
# /home/$NON_ROOT_USER_NAME/.secrets will be mapped as a
# volume for secrets from outside(no secrets in a container image)
# among secrets: GPG Private Public keypair
#
RUN mkdir -p /home/$NON_ROOT_USER_NAME/.secrets
RUN chown $NON_ROOT_USER_NAME:$NON_ROOT_USER_GRP /home/$NON_ROOT_USER_NAME/.secrets

RUN mkdir -p /workspace/signer
RUN chown $NON_ROOT_USER_NAME:$NON_ROOT_USER_GRP -R /workspace/signer
VOLUME /workspace/signer
RUN echo "whoami = [$(whoami)]"
USER $NON_ROOT_USER_NAME
RUN echo "whoami = [$(whoami)]"

WORKDIR /workspace

# COPY test /home

# CMD ["/home/test"]
