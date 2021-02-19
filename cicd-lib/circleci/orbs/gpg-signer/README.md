# Purpose

This docker container image is the definition of a utility container to put the Official GPG Signature of Gravitee Products

### Docker build, and using the image


* Build it :

```bash
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME=${CICD_LIB_OCI_REPOSITORY_NAME:-"cicd-gpg-signer"}
export DEBIAN_OCI_TAG=slim
export GPG_VERSION=2.2.23
export GPG_SIGNER_CONTAINER_IMAGE_TAG="${DEBIAN_OCI_TAG}-gpg-${GPG_VERSION}"
export GPG_SIGNER_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${GPG_SIGNER_CONTAINER_IMAGE_TAG}"

echo  "Building OCI Image [${GPG_SIGNER_OCI_IMAGE_GUN}]"

# I identify the version of the whole CI CD system, with the version of the Gravitee CI CD Orchestrator
export ORCHESTRATOR_GIT_COMMIT_ID=$(git rev-parse --short=15 HEAD)
export GITHUB_ORG=${GITHUB_ORG:-"gravitee-io"}
export OCI_VENDOR=gravitee.io
export CCI_USER_UID=$(id -u)
export CCI_USER_GID=$(id -g)
export NON_ROOT_USER_UID=${CCI_USER_UID}
export NON_ROOT_USER_NAME=$(whoami)
export NON_ROOT_USER_GID=${CCI_USER_GID}
export NON_ROOT_USER_GRP=${NON_ROOT_USER_NAME}

export OCI_BUILD_ARGS=""
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg ORCHESTRATOR_GIT_COMMIT_ID=${ORCHESTRATOR_GIT_COMMIT_ID}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg OCI_VENDOR=${OCI_VENDOR}"
export OCI_BUILD_ARGS="${OCI_BUILD_ARGS} --build-arg GITHUB_ORG=${GITHUB_ORG}"

docker build -t ${GPG_SIGNER_OCI_IMAGE_GUN} ${OCI_BUILD_ARGS}  -f ./gpg-signer/Dockerfile ./gpg-signer/

```

* Using the image :

```bash
export CICD_LIB_OCI_REPOSITORY_ORG=${CICD_LIB_OCI_REPOSITORY_ORG:-"docker.io/graviteeio"}
export CICD_LIB_OCI_REPOSITORY_NAME=${CICD_LIB_OCI_REPOSITORY_NAME:-"cicd-py-bundler"}
export DEBIAN_OCI_TAG=slim
export GPG_VERSION=2.2.23
export GPG_SIGNER_CONTAINER_IMAGE_TAG="${DEBIAN_OCI_TAG}-gpg-${GPG_VERSION}"
export GPG_SIGNER_OCI_IMAGE_GUN="${CICD_LIB_OCI_REPOSITORY_ORG}/${CICD_LIB_OCI_REPOSITORY_NAME}:${GPG_SIGNER_CONTAINER_IMAGE_TAG}"

echo  "Pulling OCI Image [${GPG_SIGNER_OCI_IMAGE_GUN}]"

docker pull ${GPG_SIGNER_OCI_IMAGE_GUN}


export SECRETHUB_ORG="graviteeio"
export SECRETHUB_REPO="cicd"
export RESTORED_GPG_PUB_KEY_FILE="$(pwd)/.signer.secrets/graviteebot.gpg.pub.key"
export RESTORED_GPG_PRIVATE_KEY_FILE="$(pwd)/.signer.secrets/graviteebot.gpg.priv.key"

secrethub read --out-file ${RESTORED_GPG_PUB_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/pub_key"
secrethub read --out-file ${RESTORED_GPG_PRIVATE_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/private_key"

export GPG_SIGNER_ENV_ARGS="-e RELEASE_VERSION=3.4.3 -e ARTIFACTORY_REPO_NAME=${ARTIFACTORY_REPO_NAME} -e ARTIFACTORY_USERNAME=${ARTIFACTORY_BOT_USER_NAME} -e ARTIFACTORY_PASSWORD=${ARTIFACTORY_BOT_USER_PWD} -e HTTPS_DEBUG_LEVEL=${HTTPS_DEBUG_LEVEL}"
export CCI_USER_UID=$(id -u)
export CCI_USER_GID=$(id -g)

export NON_ROOT_USER_NAME=$(docker inspect --format '{{ index .Config.Labels "oci.image.nonroot.user.name"}}' "${PYTHON_DOCKER}")


# --- #
# Now how to sign a file with the image
#

# ---
# The GnuPG SNIPPET
cat << EOF >./signer/gpg.script.snippet.sh
echo "# --------------------- #"
# The [/home/$NON_ROOT_USER_NAME/.secrets] is engraved into the container image
export SECRETS_HOME=/home/$NON_ROOT_USER_NAME/.secrets
export RESTORED_GPG_PUB_KEY_FILE="\${SECRETS_HOME}/graviteebot.gpg.pub.key"
export RESTORED_GPG_PRIVATE_KEY_FILE="\${SECRETS_HOME}/graviteebot.gpg.priv.key"
echo "# --------------------- #"
echo "Content of [\\\${SECRETS_HOME}/]=[\${SECRETS_HOME}/] (are the keys there in the container ?)" :
ls -allh \${SECRETS_HOME}/
echo "# --------------------- #"

export EPHEMERAL_KEYRING_FOLDER_ZERO=\$(mktemp -d)
chmod 700 \${EPHEMERAL_KEYRING_FOLDER_ZERO}
export GNUPGHOME=\${EPHEMERAL_KEYRING_FOLDER_ZERO}
echo "GPG Keys before import : "
gpg --list-keys

# ---
# Importing GPG KeyPair
gpg --batch --import \${RESTORED_GPG_PRIVATE_KEY_FILE}
gpg --import \${RESTORED_GPG_PUB_KEY_FILE}
echo "# --------------------- #"
echo "GPG Keys after import : "
gpg --list-keys
echo "# --------------------- #"
echo "  GPG version is :"
echo "# --------------------- #"
gpg --version
echo "# --------------------- #"

# ---
# now we trust ultimately the Public Key in the Ephemeral Context,
export GRAVITEEBOT_GPG_SIGNING_KEY_ID=${GRAVITEEBOT_GPG_SIGNING_KEY_ID}
echo "GRAVITEEBOT_GPG_SIGNING_KEY_ID=[\${GRAVITEEBOT_GPG_SIGNING_KEY_ID}]"

echo -e "5\\ny\\n" |  gpg --command-fd 0 --expert --edit-key \${GRAVITEEBOT_GPG_SIGNING_KEY_ID} trust

export GPG_TTY=$(tty)
echo "# ----------------------------------------------------------------"
mkdir -p ~/.gnupg/
touch ~/.gnupg/gpg.conf
echo 'no-tty' > ~/.gnupg/gpg.conf
echo "# ----------------------------------------------------------------"
echo "   Check the content of the [~/.gnupg/gpg.conf] : "
echo "# ----------------------------------------------------------------"
cat ~/.gnupg/gpg.conf
echo "# ----------------------------------------------------------------"
echo " Now SED the [~/.gnupg/gpg.conf] : "
echo "# ----------------------------------------------------------------"
sed -i "s~#no-tty~no-tty~g" ~/.gnupg/gpg.conf
echo "# ----------------------------------------------------------------"
echo " AFTER SED content of the [~/.gnupg/gpg.conf] : "
echo "# ----------------------------------------------------------------"
cat ~/.gnupg/gpg.conf
echo "# ----------------------------------------------------------------"

echo "# --------------------- #"
echo "# --- OK READY TO SIGN"
echo "# --------------------- #"
EOF
export GPG_SCRIPT_SNIPPET=$(cat ./signer/gpg.script.snippet.sh)
rm ./signer/gpg.script.snippet.sh

export PATH_TO_FILE_TO_SIGN=./my.file.to.sign
mkdir -p ./signer
cp ${PATH_TO_FILE_TO_SIGN} ./signer

export GRAVITEEBOT_GPG_PASSPHRASE=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/passphrase")
export GRAVITEEBOT_GPG_SIGNING_KEY_ID=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/key_id")
echo "GRAVITEEBOT_GPG_SIGNING_KEY_ID=[${GRAVITEEBOT_GPG_SIGNING_KEY_ID}]"


cat << EOF > ./signer/signing.script.sh
#!/bin/bash
${GPG_SCRIPT_SNIPPET}

gpg --keyid-format LONG -k "0x${GRAVITEEBOT_GPG_SIGNING_KEY_ID}"
echo "${GRAVITEEBOT_GPG_PASSPHRASE}" | gpg -u "0x${GRAVITEEBOT_GPG_SIGNING_KEY_ID}" --pinentry-mode loopback --passphrase-fd 0 --detach-sign ./signer/some-file-to-sign.txt

EOF

docker run ${GPG_SIGNER_ENV_ARGS} --user ${CCI_USER_UID}:${CCI_USER_GID} -v $PWD/signer:/workspace/signer -v $PWD/.signer.secrets:/home/${NON_ROOT_USER_NAME}/.secrets -it --rm --name gpg_signer ${GPG_SIGNER_OCI_IMAGE_GUN} ./signer/signing.script.sh
ls -allh ./signer/my.file.to.sign
ls -allh ./signer/my.file.to.sign.sig


```


### The detached signature process

Assuming we have stored a GPGP public/private RSA Key pair into our favorite secret manager (example secrethub), here is how we will sign Gravitee Products :

```bash
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ------------------------------------------------------------------------------------------------ #
# ---         Restore GPG Private and Public Keys to be able to sign Files AGAIN  !!!!!        --- #
# -------------------------------------------------------------------------------------------------#
# (replace `export SECRETHUB_ORG="graviteeio"` by `export SECRETHUB_ORG="gravitee-lab"` to test the GnuPG Identity in the https://github.com/gravitee-lab Github Organization)
export SECRETHUB_ORG="graviteeio"
export SECRETHUB_REPO="cicd"

export EPHEMERAL_KEYRING_FOLDER_ZERO=$(mktemp -d)
export RESTORE_GPG_TMP_DIR=$(mktemp -d)
export RESTORED_GPG_PUB_KEY_FILE="$(pwd)/graviteebot.gpg.pub.key"
export RESTORED_GPG_PRIVATE_KEY_FILE="$(pwd)/graviteebot.gpg.priv.key"

chmod 700 ${EPHEMERAL_KEYRING_FOLDER_ZERO}
export GNUPGHOME=${EPHEMERAL_KEYRING_FOLDER_ZERO}
# gpg --list-secret-keys
# gpg --list-pub-keys
gpg --list-keys

secrethub read --out-file ${RESTORED_GPG_PUB_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/pub_key"
secrethub read --out-file ${RESTORED_GPG_PRIVATE_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/private_key"

# ---
# - > to import the private key file, the
# - > passphrase of the private key will
# - > interactively be asked to the user.
# ---
# gpg --import ${RESTORED_GPG_PRIVATE_KEY_FILE}

# ---
# - > to import the private key file, but
# - > wthout interactive input required
# - > that's how you do it
# ---
gpg --batch --import ${RESTORED_GPG_PRIVATE_KEY_FILE}

# ---
# --- non-interactive
gpg --import ${RESTORED_GPG_PUB_KEY_FILE}
# ---
# now we trust ultimately the Public Key in the Ephemeral Context,
export GRAVITEEBOT_GPG_SIGNING_KEY_ID=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/key_id")
echo "GRAVITEEBOT_GPG_SIGNING_KEY_ID=[${GRAVITEEBOT_GPG_SIGNING_KEY_ID}]"

echo -e "5\ny\n" |  gpg --command-fd 0 --expert --edit-key ${GRAVITEEBOT_GPG_SIGNING_KEY_ID} trust

# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# -- TESTS --   Testing using the Restored GPG Key :                                   -- TESTS -- #
# -- TESTS --   to sign a file, and verify file signature                              -- TESTS -- #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #
# ------------------------------------------------------------------------------------------------ #

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ------------------------------------------------------------------------------------------------ #
# -- TESTS --                          First Let's Sign a file                         -- TESTS -- #
# ------------------------------------------------------------------------------------------------ #
cat >./some-file-to-sign.txt <<EOF
Hey I ma sooo important a file that
I am in a file which is going to be signed to proove my integrity
EOF

export GRAVITEEBOT_GPG_PASSPHRASE=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/passphrase")

# echo "${GRAVITEEBOT_GPG_PASSPHRASE}" | gpg --pinentry-mode loopback --passphrase-fd 0 --sign ./some-file-to-sign.txt

# ---
# That's Jean-Baptiste Lasselle's GPG SIGNING KEY ID for signing git commits n tags (used as example)
# export GPG_SIGNING_KEY_ID=7B19A8E1574C2883
# ---
# That's the GPG_SIGNING_KEY used buy the "Gravitee.io Bot" for git and signing any file
# export GRAVITEEBOT_GPG_SIGNING_KEY_ID=$(gpg --list-signatures -a "${GRAVITEEBOT_GPG_USER_NAME} (${GRAVITEEBOT_GPG_USER_NAME_COMMENT}) <${GRAVITEEBOT_GPG_USER_EMAIL}>" | grep 'sig' | tail -n 1 | awk '{print $2}')
export GRAVITEEBOT_GPG_SIGNING_KEY_ID=$(secrethub read "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/key_id")
echo "GRAVITEEBOT_GPG_SIGNING_KEY_ID=[${GRAVITEEBOT_GPG_SIGNING_KEY_ID}]"

gpg --keyid-format LONG -k "0x${GRAVITEEBOT_GPG_SIGNING_KEY_ID}"

# echo "${GRAVITEEBOT_GPG_PASSPHRASE}" | gpg -u "0x${GRAVITEEBOT_GPG_SIGNING_KEY_ID}" --pinentry-mode loopback --passphrase-fd 0 --sign ./some-file-to-sign.txt
# -- detached signature file is what we would want :
echo "${GRAVITEEBOT_GPG_PASSPHRASE}" | gpg -u "0x${GRAVITEEBOT_GPG_SIGNING_KEY_ID}" --pinentry-mode loopback --passphrase-fd 0 --detach-sign ./some-file-to-sign.txt


echo "# ------------------------------------------------------------------------------------------------ #"
echo "the [$(pwd)/some-file-to-sign.txt] file is the file which was signed"
ls -allh ./some-file-to-sign.txt
echo "the [$(pwd)/some-file-to-sign.txt.sig] file is the (detached) signature of the file which was signed"
ls -allh ./some-file-to-sign.txt.sig
echo "# ------------------------------------------------------------------------------------------------ #"
echo "In software, we use detached signatures, because when you sign a very "
echo "big size file, distributing the signature does not force distributing a very big file"
echo "# ------------------------------------------------------------------------------------------------ #"


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ------------------------------------------------------------------------------------------------ #
# -- TESTS --   Now test verifying the signed file, using its detached signature       -- TESTS -- #
# ------------------------------------------------------------------------------------------------ #

echo "  Now testing verifying the file with its detached signature :"
gpg --verify ./some-file-to-sign.txt.sig some-file-to-sign.txt
```


### Creating the Signature, and storing it into secret manager


* This GPG Key Pair, should naturally be considered as a criticaldigitalasset of the Gravitee.io company.
* This GPG Key Pair, should be used to sign a Gravitee Product if and only if , the validation of identified people at gravtiee has been given. Those people shall have the super power of being the only persons allowed to rotate that secret.
* The totation of that key pair must automatically update all public occurences of the Gravitee.io GPG public Key :
  * On the Gravitee.io Website
  * everytime rotation happens, social communications should broadcast this as an important news, and braodacast it in all communications channels to customers : newsletyter, social medias, Gravitee.io slack / discord bots, etc..
  * This key should be made publicly available only on channels which allow automation of the operation of updating the published public key value

Gravitee.io GPG Key management is as such :

* Gravitee.io ahs a root key, : this one is not used to sign anything (but other keys of the Gravitee.io GPG Keyring)
* All Gravitee.io Products are signed using a GPG Key which was signed by the root key.
* The root key, and all other GPG Keys used by Gravitee, form one single GPG Keyring.
* The Gravitee.io GPGP KEyring should never, ever be lost :
  * therefore we will apply to it a very reslient solution. More than 1, 2, 3 backups.
  * Its very little amount of data (probably less than 1 GB even after sevral years) , so won't cost a lot.
  * always at least 6 backups, in at least 4 remote places in the world. We'll check up standard high level strategies of the sort, all automated. No GPG Key is ever used unles all 6 backups are all confirmed, something like that. With this, the probability to lose allbackups must be calculated formally, and fully docuemented.
  * Strategies :
    * https://lwn.net/Articles/734767/
    * https://viccuad.me/blog/Revisited-secure-yourself-part-1-airgapped-computer-and-gpg-smartcards
    * what it would take to hack Gravitee.io 's Keys ? (continously asses that, and here is example : https://thehackernews.com/2016/02/hacking-air-gapped-computer.html )
    * Risks : being hacked our GPG Keys, losing our Keys so we have signed products with signatures that cannot be verified anymore. Solution : re-release all products with new signature, so clients can rotate assets in theirs Kubernetes clusters for example. So Here **Deployment Rollout should not just happen over GIT COMMIT ID, but also on Signatures**



* Init / Rotate the Gravitee.io Product Signer GPG identity :

```bash
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
#      GPG Key Pair of the Gravitee.io Products       #
#        >>> GPG version 2.x ONLY!!!                  #
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
# --- # --- # --- # --- # --- # --- # --- # --- # --- #
# -------------------------------------------------------------- #
# -------------------------------------------------------------- #
# for the Gravitee CI CD Bot in
# the https://github.com/gravitee-io Github Org
# -------------------------------------------------------------- #
# -------------------------------------------------------------- #
# https://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
export GRAVITEEBOT_GPG_USER_NAME="Gravitee.io Bot"
export GRAVITEEBOT_GPG_USER_NAME_COMMENT="Gravitee CI CD Bot in the https://github.com/gravitee-io Github Org"
export GRAVITEEBOT_GPG_USER_EMAIL="contact@gravitee.io"
export GRAVITEEBOT_GPG_PASSPHRASE="th3gr@vit331sd${RANDOM}ab@s3${RANDOM}"

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ------------------------------------------------------------------------------------------------ #
# -- CREATE THE GPG KEY PAIR for the Gravitee.io bot --                               -- SECRET -- #
# ------------------------------------------------------------------------------------------------ #
echo "# ---------------------------------------------------------------------- "
echo "Creating a GPG KEY Pair for the Gravitee.io bot"
echo "# ---------------------------------------------------------------------- "
# https://www.gnupg.org/documentation/manuals/gnupg-devel/Unattended-GPG-key-generation.html
export GNUPGHOME="$(mktemp -d)"
cat >./gravitee-io-cicd-bot.gpg <<EOF
%echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ${GRAVITEEBOT_GPG_USER_NAME}
Name-Comment: ${GRAVITEEBOT_GPG_USER_NAME_COMMENT}
Name-Email: ${GRAVITEEBOT_GPG_USER_EMAIL}
Expire-Date: 0
Passphrase: ${GRAVITEEBOT_GPG_PASSPHRASE}
# Do a commit here, so that we can later print "done" :-)
%commit
%echo done
EOF

gpg --batch --generate-key ./gravitee-io-cicd-bot.gpg
echo "GNUPGHOME=[${GNUPGHOME}] remove that directory when finished initializing secrets"
ls -allh ${GNUPGHOME}
gpg --list-secret-keys
gpg --list-keys

export GRAVITEEBOT_GPG_SIGNING_KEY_ID=$(gpg --list-signatures -a "${GRAVITEEBOT_GPG_USER_NAME} (${GRAVITEEBOT_GPG_USER_NAME_COMMENT}) <${GRAVITEEBOT_GPG_USER_EMAIL}>" | grep 'sig' | tail -n 1 | awk '{print $2}')
echo "GRAVITEEBOT - GPG_SIGNING_KEY=[${GRAVITEEBOT_GPG_SIGNING_KEY_ID}]"

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ #
# ------------------------------------------------------------------------------------------------ #
# -- SAVING SECRETS TO SECRETHUB --                                                   -- SECRET -- #
# ------------------------------------------------------------------------------------------------ #
echo "To verify the GPG signature \"Somewhere else\" we will also need the GPG Public key"
export GPG_PUB_KEY_FILE="$(pwd)/graviteebot.gpg.pub.key"
export GPG_PRIVATE_KEY_FILE="$(pwd)/graviteebot.gpg.priv.key"

# --- #
# saving public and private GPG Keys to files
gpg --export -a "${GRAVITEEBOT_GPG_USER_NAME} (${GRAVITEEBOT_GPG_USER_NAME_COMMENT}) <${GRAVITEEBOT_GPG_USER_EMAIL}>" | tee ${GPG_PUB_KEY_FILE}
# gpg --export -a "Jean-Baptiste Lasselle <jean.baptiste.lasselle.pegasus@gmail.com>" | tee ${GPG_PUB_KEY_FILE}
# -- #
# Will be interactive for private key : you
# will have to type your GPG password
gpg --export-secret-key -a "${GRAVITEEBOT_GPG_USER_NAME} (${GRAVITEEBOT_GPG_USER_NAME_COMMENT}) <${GRAVITEEBOT_GPG_USER_EMAIL}>" | tee ${GPG_PRIVATE_KEY_FILE}
# gpg --export-secret-key -a "Jean-Baptiste Lasselle <jean.baptiste.lasselle.pegasus@gmail.com>" | tee ${GPG_PRIVATE_KEY_FILE}



export SECRETHUB_ORG="graviteeio"
export SECRETHUB_REPO="cicd"
secrethub mkdir --parents "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg"

echo "${GRAVITEEBOT_GPG_USER_NAME}" | secrethub write "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/user_name"
echo "${GRAVITEEBOT_GPG_USER_NAME_COMMENT}" | secrethub write "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/user_name_comment"
echo "${GRAVITEEBOT_GPG_USER_EMAIL}" | secrethub write "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/user_email"
echo "${GRAVITEEBOT_GPG_PASSPHRASE}" | secrethub write "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/passphrase"
echo "${GRAVITEEBOT_GPG_SIGNING_KEY_ID}" | secrethub write "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/key_id"
secrethub write --in-file ${GPG_PUB_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/pub_key"
secrethub write --in-file ${GPG_PRIVATE_KEY_FILE} "${SECRETHUB_ORG}/${SECRETHUB_REPO}/graviteebot/gpg/private_key"
```

### Making the GPG Public Key publicly available

* https://keybase.io/
* beatutiful GPG push forward Web button (`GPG Key cpoied to clipboard!`)
* Quick copy paste the instructions to verify any Gravitee Product
* Utility for the Customers / Open Source Users to Verify Gravitee products signatures :
  * Circle CI Orb Command to verifiy a GPG Signature for a given file,proivded signed file, and signature file (local path or URLs)
  * Circle Orb Command to download a file, its checksums, the signatures of the file and the checksums, and verify signature of all Checksum files and the file itself.
  * Same with a docker container : then makes it usable in many CID Systems like drone etc..
  * also prepare other utilities for main CICD Toolchains : `tekton` ?

Making available all those utilities


### The Same whould be done with `Notary` : and the Admission Controller Case

The signature here is done using a TLS Certificate private Key

https://docs.docker.com/engine/security/trust/trust_delegation/#creating-delegation-keys

So the important hing here, is tocheck how the customers ' admission controllers will verify the signature :
* their Admission Controllers must configure as trusted One Certificate authority, which is in the same PKI as the CA wich signed the TLS Certificate private /public Key pair used by Gravitee to sign Docker iamges.
* So we must have a TLS Certificate dedicated to signing stuff at Gravitee.io , and carefully choose from which CA it must be signed.


### Most important security consideration : Deployment Rollout of ANY GRAVITEE PRODUCT should not just happen over GIT COMMIT ID, but also on Signatures

Any Gravitee Product deployement MUST have an automated roll out deployment  made possible over just changing its signature :

* over GPG Signatures
* over Notary Signatures (TLS Certificate based signatures)
* Any TLS Certificatebased signature.
