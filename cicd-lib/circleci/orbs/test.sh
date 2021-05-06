#!/bin/bash

set -x


# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------                     DOCKER IMAGE TESTS                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #



# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
# -----------              CIRCLECI CLI DOCKER IMAGE                     --------- #
# -------------------------------------------------------------------------------- #
# -------------------------------------------------------------------------------- #
export CCI_CLI_TEST_OPS_HOME=$(mktemp -d -t "cci-cli_tests_ops-XXXXXXXXXX")

git clone https://github.com/CircleCI-Public/terraform-orb ${CCI_CLI_TEST_OPS_HOME}/orb-src
cd ${CCI_CLI_TEST_OPS_HOME}/orb-src
git checkout v1.0.1

export CCI_CLI_VERSION=${CCI_CLI_VERSION:-"0.1.15224"}
export GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME="cicd-circleci-cli"
export CCI_CLI_CONTAINER_IMAGE_TAG="stable-latest"
export CCI_CLI_CONTAINER_IMAGE_TAG="cli-${CCI_CLI_VERSION}-debian"
export CIRCLECI_CLI_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${CCI_CLI_CONTAINER_IMAGE_TAG}"

# --->> You do not pull it , the image must locally exist, and the local must be tested before being pushed to Docker hub
# docker pull "${CIRCLECI_CLI_OCI_IMAGE_GUN}"

docker run --rm "${CIRCLECI_CLI_OCI_IMAGE_GUN}" bash -c 'circleci --help'
docker run --rm "${CIRCLECI_CLI_OCI_IMAGE_GUN}" bash -c 'circleci version'
ls -alh .
ls -alh ./src
docker run --name devops_bubble -id  "${CIRCLECI_CLI_OCI_IMAGE_GUN}" bash
docker exec -i devops_bubble bash -c 'circleci version'
docker exec -i devops_bubble bash -c 'pwd && ls -alh && mkdir -p /gio/devops/temp'
docker cp ./src devops_bubble:/gio/devops/temp
docker exec -i devops_bubble bash -c 'pwd && ls -alh && ls -alh /gio/devops/temp && ls -alh /gio/devops/temp/src'
docker exec -i devops_bubble bash -c 'cp -rT /gio/devops/temp/src /gio/devops/orb'

docker exec -i devops_bubble bash -c 'circleci orb pack /gio/devops/orb | tee /gio/devops/orb/packed-orb.yml'
docker exec -i devops_bubble bash -c 'circleci orb validate /gio/devops/orb/packed-orb.yml'

docker stop devops_bubble && docker rm devops_bubble


echo "# ------------------------------------------------------------ #"
echo "# ------------------------------------------------------------ #"
echo "# ------------------------------------------------------------ #"
echo "# ------    Testing using Circle CI CLI Authentication Setup  "
echo "# ------------------------------------------------------------ #"
echo "# ------------------------------------------------------------ #"
echo "# ------------------------------------------------------------ #"
docker run --name devops_bubble -id  "${CIRCLECI_CLI_OCI_IMAGE_GUN}" bash
export CIRCLECI_SERVER_HOST=https://circleci.com
export CIRCLECI_AUTH_TOKEN=$(cat /tmp/gravit33bot/.secrets/circleci/admin_token)
docker exec -i devops_bubble bash -c "circleci setup --token "${CIRCLECI_AUTH_TOKEN}" --host ${CIRCLECI_SERVER_HOST} --no-prompt"
docker exec -i devops_bubble bash -c "ls -alh ~/ && ls -alh ~/.circleci"
echo "# ------------------------------------------------------------ #"
echo "# --- Content of the  [~/.circleci/cli.yml] : "
docker exec -i devops_bubble bash -c "ls -alh ~/.circleci && ls -alh ~/.circleci/cli.yml && cat  ~/.circleci/cli.yml | sed 's#token:.*#token: <OBFUSCATED_CIRCLEC CI TOKEN>#g'" || true
echo "# ------------------------------------------------------------ #"
echo "# --- Content of the  [~/.circleci/update_check.yml] : "
docker exec -i devops_bubble bash -c "ls -alh ~/.circleci && ls -alh ~/.circleci/update_check.yml && cat  ~/.circleci/update_check.yml" || true
docker exec -i devops_bubble bash -c "circleci diagnostic"
