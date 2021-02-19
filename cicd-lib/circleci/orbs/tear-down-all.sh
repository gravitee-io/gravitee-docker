#!/bin/bash

set -x

# --
export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export MAVEN_VERSION=3.6.3
export OPENJDK_VERSION=11
export OCI_REPOSITORY_ORG="docker.io/graviteeio"
export OCI_REPOSITORY_NAME="cicd-maven"
export OCI_VENDOR=gravitee.io

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     TEAR DOWN IMAGES                       --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# checking docker image built in previous step is there

docker images

export DESIRED_DOCKER_TAG="maven-${MAVEN_VERSION}-openjdk-${OPENJDK_VERSION}"

docker rmi "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}"
docker rmi "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:stable-latest"
