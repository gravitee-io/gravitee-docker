#!/bin/bash
export INSTALL_OPS_HOME=$(mktemp -d -t "s3cmd_install_ops-XXXXXXXXXX")
export RESTIC_VERSION=${RESTIC_VERSION:-'0.11.0'}
export RESTIC_OS=${RESTIC_OS:-'linux'}
export RESTIC_CPU_ARCH=${RESTIC_CPU_ARCH:-'amd64'}

curl -o ./restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH}.bz2 -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH}.bz2

curl -o ./restic_${RESTIC_VERSION}_SHA256SUMS -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/SHA256SUMS
curl -o ./restic_${RESTIC_VERSION}_SHA256SUMS.asc -L https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/SHA256SUMS.asc

# use ./restic_${RESTIC_VERSION}_SHA256SUMS to check dowload integrity signature
cat ./restic_${RESTIC_VERSION}_SHA256SUMS | grep "restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH}.bz2" | sha256sum -c -

# use ./restic_${RESTIC_VERSION}_SHA256SUMS.asc to check any signature

bzip2 -d ./restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH}.bz2
mkdir -p /usr/local/bin/restic/${RESTIC_OS}/
cp ./restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH} /usr/local/bin/restic/${RESTIC_OS}/restic
cp ./restic_${RESTIC_VERSION}_SHA256SUMS /usr/local/bin/restic/${RESTIC_OS}/SHA256SUMS
cp ./restic_${RESTIC_VERSION}_SHA256SUMS.asc /usr/local/bin/restic/${RESTIC_OS}/SHA256SUMS.asc

rm ./restic_${RESTIC_VERSION}_${RESTIC_OS}_${RESTIC_CPU_ARCH}
rm ./restic_${RESTIC_VERSION}_SHA256SUMS
rm ./restic_${RESTIC_VERSION}_SHA256SUMS.asc

chmod +x /usr/local/bin/restic/${RESTIC_OS}/restic
ln -s /usr/local/bin/restic/${RESTIC_OS}/restic /usr/bin/restic

restic --help
restic version
