#!/bin/bash

set -x


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------             COCKPIT MAVEN DOCKER IMAGE                     --------- #
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
