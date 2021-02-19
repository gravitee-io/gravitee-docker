#!/bin/bash

set -x

# --
export MAVEN_VERSION=${MAVEN_VERSION:-"3.6.3"}
export OPENJDK_VERSION=${OPENJDK_VERSION:-"11"}
export OCI_REPOSITORY_ORG=${OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export OCI_REPOSITORY_NAME=${OCI_REPOSITORY_NAME:-"cicd-maven"}


export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io
export CCI_USER_UID=$(id -u)
export CCI_USER_GID=$(id -g)
# [runMavenShellScript] - Will Run Maven Shell Script with CCI_USER_UID=[1001]
# [runMavenShellScript] - Will Run Maven Shell Script with CCI_USER_GID=[1002]
# export CCI_USER_UID=1001
# export CCI_USER_GID=1002
export NON_ROOT_USER_UID=${CCI_USER_UID}
export NON_ROOT_USER_NAME=$(whoami)
export NON_ROOT_USER_GID=${CCI_USER_GID}
export NON_ROOT_USER_GRP=${NON_ROOT_USER_NAME}


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                         DOCKER PUSH                        --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     MAVEN DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# checking docker image built in previous step is there
docker images

export DESIRED_DOCKER_TAG="${MAVEN_VERSION}-openjdk-${OPENJDK_VERSION}"

# [gravitee-lab/cicd-maven/staging/docker/quay/botuser/username]
# and
# [gravitee-lab/cicd-maven/staging/docker/quay/botoken/token]
# --> are to be set with secrethub cli, and 2 Circle CI Env. Var. have to
# be set for [Secrethub CLI Auth], at project, or context level
export SECRETHUB_ORG=${SECRETHUB_ORG:-"graviteeio"}
export SECRETHUB_REPO=${SECRETHUB_REPO:-"cicd"}

export DOCKERHUB_BOT_USER_NAME=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/infra/dockerhub-user-name")
export DOCKERHUB_BOT_USER_TOKEN=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/infra/dockerhub-user-token")

docker login --username="${DOCKERHUB_BOT_USER_NAME}" -p="${DOCKERHUB_BOT_USER_TOKEN}"

echo "checking [date time] (sometimes data time in Circle CI pipelines is wrong, so that Container registry rejects the [docker push]...)"
date

export IMAGE_TAG_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.tag"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export GH_ORG_LABEL=$(docker inspect --format '{{ index .Config.Labels "cicd.github.org"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export NON_ROOT_USER_NAME_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.nonroot.user.name"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export NON_ROOT_USER_GRP_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.nonroot.user.group"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")

echo " IMAGE_TAG_LABEL=[${IMAGE_TAG_LABEL}]"
echo " GH_ORG_LABEL=[${GH_ORG_LABEL}]"
echo " NON_ROOT_USER_NAME_LABEL=[${NON_ROOT_USER_NAME_LABEL}]"
echo " NON_ROOT_USER_GRP_LABEL=[${NON_ROOT_USER_GRP_LABEL}]"

docker push "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}"
docker push "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:stable-latest"





# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     S3CMD DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export S3CMD_VERSION=${S3CMD_VERSION:-"2.1.0"}
# I identify the version of the whole CI CD system,wih the versionof the Gravitee CI CD Orchestrator
export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-s3cmd"
export S3CMD_CONTAINER_IMAGE_TAG="s3cmd-${S3CMD_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
export S3CMD_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${S3CMD_CONTAINER_IMAGE_TAG}"

echo  "Pushing OCI Image [${S3CMD_OCI_IMAGE_GUN}] with [stable-latest] tag"

docker tag ${S3CMD_OCI_IMAGE_GUN} "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"

# ---
# always push both the original tag, and the same tagged as stable-latest
# ---
#
docker push "${S3CMD_OCI_IMAGE_GUN}"
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                PYTHON BUNDLER DOCKER IMAGE                 --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-py-bundler"
export PY_BUNDLER_CONTAINER_IMAGE_TAG="py-bundler-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
export PY_BUNDLER_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${PY_BUNDLER_CONTAINER_IMAGE_TAG}"

echo  "Pushing OCI Image [${PY_BUNDLER_OCI_IMAGE_GUN}]"

docker tag ${PY_BUNDLER_OCI_IMAGE_GUN} "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"

# ---
# always push both the original tag, and the same tagged as stable-latest
# ---
#
docker push "${PY_BUNDLER_OCI_IMAGE_GUN}"
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     RESTIC DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export RESTIC_VERSION=${RESTIC_VERSION:-"0.11.0"}
# I identify the version of the whole CI CD system,wih the versionof the Gravitee CI CD Orchestrator
export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-restic"
export RESTIC_CONTAINER_IMAGE_TAG="restic-${RESTIC_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
export RESTIC_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${RESTIC_CONTAINER_IMAGE_TAG}"

echo  "Pushing OCI Image [${RESTIC_OCI_IMAGE_GUN}] with [stable-latest] tag"

docker tag ${RESTIC_OCI_IMAGE_GUN} "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"

# ---
# always push both the original tag, and the same tagged as stable-latest
# ---
#
docker push "${RESTIC_OCI_IMAGE_GUN}"
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"


# ---
# ---
# ---


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                GPG SIGNER DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #


export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-gpg-signer"
export DEBIAN_OCI_TAG=buster-slim
export GPG_VERSION=2.2.23
export GPG_SIGNER_CONTAINER_IMAGE_TAG="${DEBIAN_OCI_TAG}-gpg-${GPG_VERSION}"
export GPG_SIGNER_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${GPG_SIGNER_CONTAINER_IMAGE_TAG}"

echo  "Pushing OCI Image [${GPG_SIGNER_OCI_IMAGE_GUN}]"

docker tag ${GPG_SIGNER_OCI_IMAGE_GUN} "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"

docker push ${GPG_SIGNER_OCI_IMAGE_GUN}
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"
