#!/bin/bash
export INSTALL_OPS_HOME=$(mktemp -d -t "s3cmd_install_ops-XXXXXXXXXX")
export S3CMD_VERSION=${S3CMD_VERSION:-'2.1.0'}
curl -LO https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_VERSION}/s3cmd-${S3CMD_VERSION}.zip
curl -LO https://github.com/s3tools/s3cmd/releases/download/v${S3CMD_VERSION}/s3cmd-${S3CMD_VERSION}.zip.asc
# okay this is a GPG based signature check
# Si need GPG installed, a GPG keyring context
# gpg --keyid-format long --list-options show-keyring s3cmd-.zip.asc
# I will need the GPG Public Key of the project, whichI could not find anywhere yet, so
# I opened an issue to ask for it : https://github.com/s3tools/s3cmd/issues/1173
# https://serverfault.com/questions/896228/how-to-verify-a-file-using-an-asc-signature-file
# once verifications finished

unzip ./s3cmd-${S3CMD_VERSION}.zip -d ${INSTALL_OPS_HOME}
export WHERE_IAM=$(pwd)
cd ${INSTALL_OPS_HOME}/s3cmd-2.1.0
python setup.py install
cd ${WHERE_IAM}
rm -fr ${INSTALL_OPS_HOME}
s3cmd --version
