#!/bin/bash

set -x


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     MAVEN DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

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
# -----------                         DOCKER BUILD                       --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export DESIRED_DOCKER_TAG="${MAVEN_VERSION}-openjdk-${OPENJDK_VERSION}"

export OCI_BUILD_ARGS="--build-arg MAVEN_VERSION=${MAVEN_VERSION} --build-arg OPENJDK_VERSION=${OPENJDK_VERSION} --build-arg OCI_VENDOR=${OCI_VENDOR} --build-arg GITHUB_ORG=${GITHUB_ORG}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_UID=${NON_ROOT_USER_UID} --build-arg NON_ROOT_USER_GID=${NON_ROOT_USER_GID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_NAME=${NON_ROOT_USER_NAME} --build-arg NON_ROOT_USER_GRP=${NON_ROOT_USER_GRP}"

docker build -t "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}" ${OCI_BUILD_ARGS} -f ./maven/Dockerfile ./maven/
docker tag "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}" "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:stable-latest"



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

echo  "Building OCI Image [${S3CMD_OCI_IMAGE_GUN}]"

# docker build -t graviteeio/s3cmd:clever-cloud-0.0.1 .
export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io

export OCI_BUILD_ARGS="--build-arg S3CMD_VERSION=${S3CMD_VERSION}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg ORCHESTRATOR_GIT_COMMIT_ID=${ORCHESTRATOR_GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"


docker build -t ${S3CMD_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./s3cmd/Dockerfile ./s3cmd/

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

echo  "Building OCI Image [${PY_BUNDLER_OCI_IMAGE_GUN}]"

export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io
export CCI_USER_UID=$(id -u)
export CCI_USER_GID=$(id -g)
export NON_ROOT_USER_UID=${CCI_USER_UID}
export NON_ROOT_USER_NAME=$(whoami)
export NON_ROOT_USER_GID=${CCI_USER_GID}
export NON_ROOT_USER_GRP=${NON_ROOT_USER_NAME}

export OCI_BUILD_ARGS=""
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg ORCHESTRATOR_GIT_COMMIT_ID=${ORCHESTRATOR_GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_UID=${NON_ROOT_USER_UID} --build-arg NON_ROOT_USER_GID=${NON_ROOT_USER_GID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_NAME=${NON_ROOT_USER_NAME} --build-arg NON_ROOT_USER_GRP=${NON_ROOT_USER_GRP}"

docker build -t ${PY_BUNDLER_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./python/Dockerfile ./python/


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     RESTIC DOCKER IMAGE                    --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export RESTIC_VERSION=${RESTIC_VERSION:-"0.11.0"}
# I identify the version of the whole CI CD system,wih the versionof the Gravitee CI CD Orchestrator
export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-restic"
export RESTIC_CONTAINER_IMAGE_TAG="restic-${RESTIC_VERSION}-cicd-${ORCHESTRATOR_GIT_COMMIT_ID}"
export RESTIC_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${RESTIC_CONTAINER_IMAGE_TAG}"

echo  "Building OCI Image [${RESTIC_OCI_IMAGE_GUN}]"

# docker build -t graviteeio/restic:clever-cloud-0.0.1 .
export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io

export OCI_BUILD_ARGS="--build-arg RESTIC_VERSION=${RESTIC_VERSION}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg ORCHESTRATOR_GIT_COMMIT_ID=${ORCHESTRATOR_GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"


docker build -t ${RESTIC_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./restic/Dockerfile ./restic/


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                 GPG SIGNER DOCKER IMAGE                    --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-gpg-signer"
export DEBIAN_OCI_TAG=buster-slim
export GPG_VERSION=2.2.23
export GPG_SIGNER_CONTAINER_IMAGE_TAG="${DEBIAN_OCI_TAG}-gpg-${GPG_VERSION}"
export GPG_SIGNER_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${GPG_SIGNER_CONTAINER_IMAGE_TAG}"

echo  "Building OCI Image [${GPG_SIGNER_OCI_IMAGE_GUN}]"

# I identify the version of the whole CI CD system, with the version of the Gravitee CI CD Orchestrator
export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io
export CCI_USER_UID=$(id -u)
export CCI_USER_GID=$(id -g)
export NON_ROOT_USER_UID=${CCI_USER_UID}
export NON_ROOT_USER_NAME=$(whoami)
export NON_ROOT_USER_GID=${CCI_USER_GID}
export NON_ROOT_USER_GRP=${NON_ROOT_USER_NAME}

export OCI_BUILD_ARGS=""
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg ORCHESTRATOR_GIT_COMMIT_ID=${ORCHESTRATOR_GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg DEBIAN_OCI_TAG=${DEBIAN_OCI_TAG}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_UID=${NON_ROOT_USER_UID} --build-arg NON_ROOT_USER_GID=${NON_ROOT_USER_GID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg NON_ROOT_USER_NAME=${NON_ROOT_USER_NAME} --build-arg NON_ROOT_USER_GRP=${NON_ROOT_USER_GRP}"

docker build -t ${GPG_SIGNER_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./gpg-signer/Dockerfile ./gpg-signer/
