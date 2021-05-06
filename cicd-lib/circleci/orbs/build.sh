#!/bin/bash

set -x


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     MAVEN DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# --
export MAVEN_VERSION=${MAVEN_VERSION:-"3.6.3"}
export OPENJDK_VERSION=${OPENJDK_VERSION:-"11.0.3"}
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
# -----------                         DOCKER BUILD                       --------- #
# -------------------------------------------------------------------------------- #

export DESIRED_DOCKER_TAG="${MAVEN_VERSION}-openjdk-${OPENJDK_VERSION}"

export OCI_BUILD_ARGS="--build-arg MAVEN_VERSION=${MAVEN_VERSION} --build-arg OPENJDK_VERSION=${OPENJDK_VERSION} --build-arg OCI_VENDOR=${OCI_VENDOR} --build-arg GITHUB_ORG=${GITHUB_ORG}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GIO_PRODUCT_NAME=${GIO_PRODUCT_NAME}"
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
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-s3cmd"
export S3CMD_CONTAINER_IMAGE_TAG="s3cmd-${S3CMD_VERSION}"
export S3CMD_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${S3CMD_CONTAINER_IMAGE_TAG}"

echo  "Building OCI Image [${S3CMD_OCI_IMAGE_GUN}]"

export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io

export OCI_BUILD_ARGS="--build-arg S3CMD_VERSION=${S3CMD_VERSION}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GIT_COMMIT_ID=${GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"


docker build -t ${S3CMD_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./s3cmd/Dockerfile ./s3cmd/
docker tag "${S3CMD_OCI_IMAGE_GUN}" "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"



# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------              CIRCLECI CLI DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export CCI_CLI_VERSION=${CCI_CLI_VERSION:-"0.1.15224"}
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-circleci-cli"
export CCI_CLI_CONTAINER_IMAGE_TAG="cli-${CCI_CLI_VERSION}-debian"
export CIRCLECI_CLI_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${CCI_CLI_CONTAINER_IMAGE_TAG}"

echo  "Building OCI Image [${CIRCLECI_CLI_OCI_IMAGE_GUN}]"

export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io

export OCI_BUILD_ARGS="--build-arg CCI_CLI_VERSION=${CCI_CLI_VERSION}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GIT_COMMIT_ID=${GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"


docker build -t ${CIRCLECI_CLI_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./circleci-cli/Dockerfile ./circleci-cli/
docker tag "${CIRCLECI_CLI_OCI_IMAGE_GUN}" "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"
