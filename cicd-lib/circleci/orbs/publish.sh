#!/bin/bash

set -x

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
# -------------------------------------------------------------------------------- #
# -----------                         DOCKER PUSH                        --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                          MAVEN DOCKER IMAGE                --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

# checking docker image built in previous step is there
docker images

export DESIRED_DOCKER_TAG="${MAVEN_VERSION}-openjdk-${OPENJDK_VERSION}"

echo "checking [date time] (sometimes data time in Circle CI pipelines is wrong, so that Container registry rejects the [docker push]...)"
date

export IMAGE_TAG_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.tag"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export IMAGE_FROM_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.from"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export GH_ORG_LABEL=$(docker inspect --format '{{ index .Config.Labels "cicd.github.org"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export GIO_PRODUCT_NAME_LABEL=$(docker inspect --format '{{ index .Config.Labels "io.gravitee.product.name"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export NON_ROOT_USER_NAME_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.nonroot.user.name"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")
export NON_ROOT_USER_GRP_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.nonroot.user.group"}}' "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}")

echo " IMAGE_TAG_LABEL=[${IMAGE_TAG_LABEL}]"
echo " IMAGE_FROM_LABEL=[${IMAGE_FROM_LABEL}]"
echo " GH_ORG_LABEL=[${GH_ORG_LABEL}]"
echo " GIO_PRODUCT_NAME_LABEL=[${GIO_PRODUCT_NAME_LABEL}]"
echo " NON_ROOT_USER_NAME_LABEL=[${NON_ROOT_USER_NAME_LABEL}]"
echo " NON_ROOT_USER_GRP_LABEL=[${NON_ROOT_USER_GRP_LABEL}]"

echo "# ----------------------------------------------------------------------------------------------- #"
echo "   Will docker push: [${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}]"
echo "   Will docker push: [${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:latest]"
echo "# ----------------------------------------------------------------------------------------------- #"


docker push "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:${DESIRED_DOCKER_TAG}"
# docker push "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:stable-latest"
docker push "${OCI_REPOSITORY_ORG}/${OCI_REPOSITORY_NAME}:latest"


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     S3CMD DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #

export S3CMD_VERSION=${S3CMD_VERSION:-"2.1.0"}
# I identify the version of the whole CI CD system,wih the versionof the Gravitee CI CD Orchestrator
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-s3cmd"
export S3CMD_CONTAINER_IMAGE_TAG="s3cmd-${S3CMD_VERSION}"
export S3CMD_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${S3CMD_CONTAINER_IMAGE_TAG}"

# ---
# always push both the original tag, and the same tagged as stable-latest
# ---
#
echo  "Pushing OCI Image [${S3CMD_OCI_IMAGE_GUN}] with [stable-latest] tag : "
echo "  Will docker push [${S3CMD_OCI_IMAGE_GUN}]"
echo "  Will docker push [${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest]"

docker push "${S3CMD_OCI_IMAGE_GUN}"
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"



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

# ---
# Always push both the original tag, and the same tagged as stable-latest
# ---
#
echo  "Pushing OCI Image [${CIRCLECI_CLI_OCI_IMAGE_GUN}] with [stable-latest] tag : "
echo "  Will docker push [${CIRCLECI_CLI_OCI_IMAGE_GUN}]"
echo "  Will docker push [${CIRCLECI_CLI_OCI_IMAGE_GUN}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest]"

docker push "${S3CMD_OCI_IMAGE_GUN}"
docker push "${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:stable-latest"
