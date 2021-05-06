# The `s3cmd`


## What is `s3cmd` ?

`s3cmd` is a command line utility to manage an S3 bucket, a bit like `rclone`

## Whys `s3cmd`

`s3cmd` is used in the Gravitee CI CD System to publish to an S3 bucket, the zip files resulting of the maven build in  each Gravitee dev. git repository

## Meta data of the image : Labels

When you use the `cicd-s3cmd` Gravitee CICD Sysem container image, always use the `stable-latest`, tag, and then you can get the following metadata(e.g.the version of `s3cmd` in the container), like this :

```bash

export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME=${CICD_LIB_OCI_REPOSITORY_NAME:-"cicd-s3cmd"}
export S3CMD_CONTAINER_IMAGE_TAG=${S3CMD_CONTAINER_IMAGE_TAG:-"stable-latest"}
export S3CMD_DOCKER="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${S3CMD_CONTAINER_IMAGE_TAG}"

docker pull "${S3CMD_DOCKER}"

# ---
# Now getting the image metadata fromthe stable latest 'cicd-s3cmd' container image :
# ---

export IMAGE_TAG_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.tag"}}' "${S3CMD_DOCKER}")
export GH_ORG_LABEL=$(docker inspect --format '{{ index .Config.Labels "cicd.github.org"}}' "${S3CMD_DOCKER}")
export OCI_VENDOR=$(docker inspect --format '{{ index .Config.Labels "vendor"}}' "${S3CMD_DOCKER}")
export MAINTAINER=$(docker inspect --format '{{ index .Config.Labels "maintainer"}}' "${S3CMD_DOCKER}")
export S3CMD_VERSION=$(docker inspect --format '{{ index .Config.Labels "cicd.s3cmd.version"}}' "${S3CMD_DOCKER}")
export ORCHESTRATOR_GIT_COMMIT_ID=$(docker inspect --format '{{ index .Config.Labels "cicd.orchestrator.git.commit.id"}}' "${S3CMD_DOCKER}")

echo " Container image tag (underlying container image tag) is = [${IMAGE_TAG_LABEL}]"
echo " Gravitee CI CD Orchestrator Git Commit ID is = [${ORCHESTRATOR_GIT_COMMIT_ID}]"
echo " 's3cmd' version in container is = [${S3CMD_VERSION}]"
echo " The Github Org for which this image is designed for, is =[${GH_ORG_LABEL}]"
echo " Vendor name of the image is =[${OCI_VENDOR}]"
echo " the maintainer email address of the image is =[${MAINTAINER}]"

```
