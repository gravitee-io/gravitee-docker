#!/bin/bash
export INSTALL_OPS_HOME=$(mktemp -d -t "cci-cli_install_ops-XXXXXXXXXX")

# export CCI_CLI_VERSION=${CCI_CLI_VERSION:-'2.1.0'}
curl -iv -L https://github.com/CircleCI-Public/circleci-cli/releases/latest/ > ./fetch.latest.version
export CCI_LATEST_VERSION=$(cat ./fetch.latest.version | grep 'location: ' | awk -F '/' '{print $NF}' | cut -d "v" -f 2 | tr -d ' ' | tr -d '\r')
echo "Latest version of Circle CI CLI is [${CCI_LATEST_VERSION}]"

rm ./fetch.latest.version

if [ "x${CCI_CLI_VERSION}" == "x" ]; then
  echo "CCI_CLI_VERSION env. variable is not set, so will install latest version of Circle CI CLI : [${CCI_LATEST_VERSION}]"
  export CCI_CLI_VERSION=${CCI_LATEST_VERSION}
fi;

# Install the CircleCI CLI tool.
# https://github.com/CircleCI-Public/circleci-cli
#
# Dependencies: curl, cut
#
# The version to install and the binary location can be passed in via CCI_CLI_VERSION and CCI_CLI_INSTALL_DIR respectively.
#

set -o errexit

echo "Starting installation."

# GitHub's URL for the latest release, will redirect.
GITHUB_BASE_URL="https://github.com/CircleCI-Public/circleci-cli"
CCI_CLI_INSTALL_DIR="${CCI_CLI_INSTALL_DIR:-/usr/local/bin}"

echo "Installing CircleCI CLI v${CCI_CLI_VERSION}"

# Run the script in a temporary directory that we know is empty.
cd "${INSTALL_OPS_HOME}"

function error {
  echo "An error occured installing the tool."
  echo "The contents of the directory ${INSTALL_OPS_HOME} have been left in place to help to debug the issue."
}

trap error ERR

# Determine release filename. This can be expanded with CPU arch in the future.
case "$(uname)" in
	Linux)
		OS='linux'
	;;
	Darwin)
		OS='darwin'
	;;
	*)
		echo "This operating system is not supported."
		exit 1
	;;
esac

RELEASE_URL="${GITHUB_BASE_URL}/releases/download/v${CCI_CLI_VERSION}/circleci-cli_${CCI_CLI_VERSION}_${OS}_amd64.tar.gz"

# Download & unpack the release tarball.
curl -sL --retry 3 "${RELEASE_URL}" | tar zx --strip 1

echo "Installing to $CCI_CLI_INSTALL_DIR"
install circleci "$CCI_CLI_INSTALL_DIR"

command -v circleci

# Delete the working directory when the install was successful.
rm -r "$INSTALL_OPS_HOME"
