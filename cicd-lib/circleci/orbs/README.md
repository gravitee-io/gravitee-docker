# The CI CD System Container images

### Running local

To test to buld recipe of the container images, I used :

```bash

git config --global commit.gpgsign true
git config --global user.name "Jean-Baptiste-Lasselle"
git config --global user.email jean.baptiste.lasselle.pegasus@gmail.com
git config --global user.signingkey 7B19A8E1574C2883

git config --global --list

# will re-define the default identity in use
# https://docstore.mik.ua/orelly/networking_2ndEd/ssh/ch06_04.htm
ssh-add ~/.ssh.perso.backed/id_rsa

export GIT_SSH_COMMAND='ssh -i ~/.ssh.perso.backed/id_rsa'
ssh -Ti ~/.ssh.perso.backed/id_rsa git@github.com
ssh -Ti ~/.ssh.perso.backed/id_rsa git@gitlab.com


export OPS_HOME="$(mktemp -d)"
export ORBINOID_VERSION=feature/tests-mgmt

git clone git@github.com:gravitee-io/gravitee-circleci-orbinoid.git ${OPS_HOME}

cd ${OPS_HOME}

git checkout ${ORBINOID_VERSION}

cd orb/lib-docker/
./build.sh

# ------------------ #
# ------------------ #
# --- Tear down
# ------------------ #
# ------------------ #
./tear-down.sh
# ------------------ #
# docker system prune -f --all && docker system prune -f --volumes

```
