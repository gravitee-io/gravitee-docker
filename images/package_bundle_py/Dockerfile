FROM python:3-onbuild
# FROM python:3

# ARG S3CMD_VERSION=$S3CMD_VERSION
ARG ORCHESTRATOR_GIT_COMMIT_ID=$ORCHESTRATOR_GIT_COMMIT_ID
ARG GITHUB_ORG=$GITHUB_ORG
ARG OCI_VENDOR=$GITHUB_ORG
# LABEL oci.image.tag=maven:"${MAVEN_VERSION}"-openjdk-"${OPENJDK_VERSION}"
# LABEL cicd.s3cmd.version="${S3CMD_VERSION}"
LABEL cicd.orchestrator.git.commit.id="${ORCHESTRATOR_GIT_COMMIT_ID}"
# LABEL oci.image.tag="python-${S3CMD_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
LABEL oci.image.tag="python3-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
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
RUN echo "whoami = [$(whoami)]"

WORKDIR /usr/src/app
COPY requirements.txt ./
COPY start.sh /usr/src/app
RUN chmod a+x /usr/src/app/start.sh
COPY package_bundles.py .
RUN pip install --no-cache-dir -r requirements.txt

RUN chown $NON_ROOT_USER_NAME:$NON_ROOT_USER_GRP -R /usr/src
USER $NON_ROOT_USER_NAME
RUN echo "whoami = [$(whoami)]"

ENV RELEASE_VERSION=$RELEASE_VERSION
ENV ARTIFACTORY_USERNAME=$ARTIFACTORY_USERNAME
ENV ARTIFACTORY_PASSWORD=$ARTIFACTORY_PASSWORD
ENV ARTIFACTORY_REPO_NAME=$ARTIFACTORY_REPO_NAME
ENV HTTPS_DEBUG_LEVEL=$HTTPS_DEBUG_LEVEL

RUN mkdir -p /usr/src/gio_files
VOLUME /usr/src/gio_files


CMD [ "/usr/src/app/start.sh" ]
# CMD [ "python", "./package_bundles.py" ]
