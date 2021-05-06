# The `Circle CI CLI` Docker image

This Docker image :
* Is designed to use in Circle CI CI/CD System: it has a built in `circleci` User
* Contains the CircleCI CLI : the `circleci` executable

## How to use


```bash

export CCI_CLI_VERSION=${CCI_CLI_VERSION:-"0.1.15224"}
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-circleci-cli"
export CCI_CLI_CONTAINER_IMAGE_TAG="cli-${CCI_CLI_VERSION}-debian"
export CCI_CLI_CONTAINER_IMAGE_TAG="stable-latest"
export CIRCLECI_CLI_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${CCI_CLI_CONTAINER_IMAGE_TAG}"

docker pull "${CIRCLECI_CLI_OCI_IMAGE_GUN}"

docker run -rm  $PWD:/gio/devops/orb "${CIRCLECI_CLI_OCI_IMAGE_GUN}" bash -c 'circleci --version'

```

## Meta data of the image : Labels

When you use the `graviteeio/cicd-circleci-cli` Gravitee CICD Sysem container image, always use the `stable-latest`, tag, and then you can get the following metadata(e.g.the version of `s3cmd` in the container), like this :

```bash
export CCI_CLI_VERSION=${CCI_CLI_VERSION:-"0.1.15224"}
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-circleci-cli"
export CCI_CLI_CONTAINER_IMAGE_TAG="cli-${CCI_CLI_VERSION}-debian"
export CCI_CLI_CONTAINER_IMAGE_TAG="stable-latest"
export CIRCLECI_CLI_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${CCI_CLI_CONTAINER_IMAGE_TAG}"

docker pull "${CIRCLECI_CLI_OCI_IMAGE_GUN}"

docker run -rm  $PWD:/gio/devops/orb
# ---
# Now getting the image metadata fromthe stable latest 'cicd-circleci-cli' container image :
# ---

export IMAGE_TAG_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.tag"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")
export GH_ORG_LABEL=$(docker inspect --format '{{ index .Config.Labels "cicd.github.org"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")
export OCI_VENDOR=$(docker inspect --format '{{ index .Config.Labels "vendor"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")
export MAINTAINER=$(docker inspect --format '{{ index .Config.Labels "maintainer"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")
export S3CMD_VERSION=$(docker inspect --format '{{ index .Config.Labels "cicd.s3cmd.version"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")
export ORCHESTRATOR_GIT_COMMIT_ID=$(docker inspect --format '{{ index .Config.Labels "cicd.orchestrator.git.commit.id"}}' "${CIRCLECI_CLI_OCI_IMAGE_GUN}")

echo " Container image tag (underlying container image tag) is = [${IMAGE_TAG_LABEL}]"
echo " Gravitee CI CD Orchestrator Git Commit ID is = [${ORCHESTRATOR_GIT_COMMIT_ID}]"
echo " 'circleci' CLI version in container is = [${S3CMD_VERSION}]"
echo " The Github Org for which this image is designed for, is =[${GH_ORG_LABEL}]"
echo " Vendor name of the image is =[${OCI_VENDOR}]"
echo " the maintainer email address of the image is =[${MAINTAINER}]"

```
