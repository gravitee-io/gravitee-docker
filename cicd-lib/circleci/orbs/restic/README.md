# The `restic`


## What is `restic` ?

`restic` is a command line utility, manage backup restore operations, and weuse it in CI CD as a client for S3 bucket.


## Whys `restic`

`restic` is used in the Gravitee CI CD System to publish to an S3 bucket, the zip files resulting of the maven build in  each Gravitee dev. git repository

It is preferred to AWS CLI and `s3cmd`, because it has the ability to preserve a lot of file attributes, which is important in backup restore operations, and for moving around across storage devices, GRaviee distributed fiels.

## Meta data of the image : Labels

When you use the `cicd-restic` Gravitee CICD Sysem container image, always use the `stable-latest`, tag, and then you can get the following metadata(e.g.the version of `restic` in the container), like this :

```bash

export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME=${CICD_LIB_OCI_REPOSITORY_NAME:-"cicd-restic"}
export RESTIC_CONTAINER_IMAGE_TAG=${RESTIC_CONTAINER_IMAGE_TAG:-"stable-latest"}
export RESTIC_DOCKER="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${RESTIC_CONTAINER_IMAGE_TAG}"

docker pull "${RESTIC_DOCKER}"

# ---
# Now getting the image metadata fromthe stable latest 'cicd-restic' container image :
# ---

export IMAGE_TAG_LABEL=$(docker inspect --format '{{ index .Config.Labels "oci.image.tag"}}' "${RESTIC_DOCKER}")
export GH_ORG_LABEL=$(docker inspect --format '{{ index .Config.Labels "cicd.github.org"}}' "${RESTIC_DOCKER}")
export OCI_VENDOR=$(docker inspect --format '{{ index .Config.Labels "vendor"}}' "${RESTIC_DOCKER}")
export MAINTAINER=$(docker inspect --format '{{ index .Config.Labels "maintainer"}}' "${RESTIC_DOCKER}")
export RESTIC_VERSION=$(docker inspect --format '{{ index .Config.Labels "cicd.restic.version"}}' "${RESTIC_DOCKER}")
export ORCHESTRATOR_GIT_COMMIT_ID=$(docker inspect --format '{{ index .Config.Labels "cicd.orchestrator.git.commit.id"}}' "${RESTIC_DOCKER}")

echo " Container image tag (underlying container image tag) is = [${IMAGE_TAG_LABEL}]"
echo " Gravitee CI CD Orchestrator Git Commit ID is = [${ORCHESTRATOR_GIT_COMMIT_ID}]"
echo " 'restic' verson in container is = [${RESTIC_VERSION}]"
echo " The Github Org for which this image is designed for, is =[${GH_ORG_LABEL}]"
echo " Vendor name of the image is =[${OCI_VENDOR}]"
echo " the maintainer email address of the image is =[${MAINTAINER}]"

```
