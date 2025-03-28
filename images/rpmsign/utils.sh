#!/usr/bin/env bash
set -euo pipefail

format_gpg_key(){
  sed -E '
    s/(-----[A-Z ]*-----) /\1\n/g;
    s/ (-----[A-Z ]*-----)/\n\1/g;
    /-----BEGIN PGP [A-Z ]*-----/a\

    /-----BEGIN PGP [A-Z ]*-----/,/-----END PGP [A-Z ]*-----/ {
      /-----BEGIN PGP [A-Z ]*-----/b;
      /-----END PGP [A-Z ]*-----/b;
      s/ ([a-zA-Z0-9+/=]{4,})/\n\1/g
    }'
}

prerequisites(){
  if [[ -z "${PGP_KEY_NAME:-}" || -z "${PGP_KEY_PUBLIC:-}" || -z "${PGP_KEY_PRIVATE:-}" || -z "${PGP_KEY_PASSPHRASE:-}" ]]
  then
    cat 1>&2 <<EOF
Some environment variable are missing:
PGP_KEY_NAME=${PGP_KEY_NAME:-}
PGP_KEY_PUBLIC=${PGP_KEY_PUBLIC:-}
PGP_KEY_PRIVATE=${PGP_KEY_PRIVATE:-}
PGP_KEY_PASSPHRASE=${PGP_KEY_PASSPHRASE:-}
EOF
    return 1
  elif [[ $(ls -1 /rpms/*.rpm | wc -l) -eq 0 ]]
  then
    echo "No RPM file found in /rpms" >&2
  fi
}

import_gpg_keys(){
  local public_key_file private_key_file
  public_key_file="$(mktemp /tmp/gpg_public_key_XXXX.key)"
  echo "${PGP_KEY_PUBLIC}" | format_gpg_key > "${public_key_file}"
  private_key_file="$(mktemp /tmp/gpg_private_key_XXXX.key)"
  echo "${PGP_KEY_PRIVATE}" | format_gpg_key > "${private_key_file}"

  gpg2 --import --batch "${public_key_file}"
  gpg2 --import --batch "${private_key_file}"
}

configure_gpg_agent(){
  echo "allow-preset-passphrase" > ~/.gnupg/gpg-agent.conf
  gpg-connect-agent reloadagent /bye

  while read -r preset
  do
    /usr/lib/gnupg2/gpg-preset-passphrase --passphrase "${PGP_KEY_PASSPHRASE}" --preset "${preset}"
  done < <(gpg2 --list-secret-keys --with-keygrip --with-colons "${PGP_KEY_NAME}" | sed -n '/^grp/{s/^grp:*\(.*\):$/\1/p}')
  # Documentation for parsing gpg output:
  # https://git.gnupg.org/cgi-bin/gitweb.cgi?p=gnupg.git;a=blob_plain;f=doc/DETAILS
}

configure_rpm(){
  local public_key_file

  cat > ~/.rpmmacros <<EOF
%_signature gpg
%_gpg_path ${HOME}/.gnupg
%_gpg_name ${PGP_KEY_NAME}
%_gpgbin /usr/bin/gpg
EOF

  public_key_file="$(mktemp /tmp/gpg_public_key_XXXX.key)"
  # even if the public key file could exist, we export new one to be sure that it is armored.
  gpg2 --armor --batch --export "${PGP_KEY_NAME}" > "${public_key_file}"
  rpmkeys --import "${public_key_file}"
}

rpm_sign(){
  local keyid

  if [[ -d /rpms ]]
  then
    keyid="$(gpg2 --list-keys --with-keygrip --with-colons "${PGP_KEY_NAME}" | grep "^pub" | cut -d ":" -f 5)"

    for file in /rpms/*.rpm
    do
      rpmsign --key-id="${keyid}" --addsign "${file}"
    done
  else
    cat 1>&2 <<EOF
No RPMs to sign.
mount volume to /rpms in docker container to sign RPMs.
EOF
  fi
}

rpm_check(){
  echo "### RPM check ###"
  for file in /rpms/*.rpm
  do
    echo "### ${file}"
    rpmkeys --checksig "${file}"
  done
}

rpm_info(){
  echo "### RPM info ###"
  for file in /rpms/*.rpm
  do
    echo "### ${file}"
    rpm -pqi "${file}"
  done
}

scenario_sign_rpm(){
  prerequisites
  import_gpg_keys
  configure_gpg_agent
  configure_rpm
  rpm_sign
  rpm_check
  rpm_info
}

list_keys(){
    gpg2 --list-keys --with-keygrip
    gpg2 --list-secret-keys --with-keygrip
}

generate_pgp_key(){
  local keyname="${1:-${PGP_KEY_NAME:-Gravitee.io Bot}}"
  local keypass="${2:-${PGP_KEY_PASSPHRASE:-super secure OR not @ all}}"
  gpg2 --gen-key --batch <(cat <<EOF
%echo Generating a default key
Key-Type: RSA
Key-Length: 2048
Subkey-Type: RSA
Subkey-Length: 2048
Subkey-Usage: Encrypt
Name-Real: ${keyname}
Name-Comment: test with random keys
Name-Email: test@graviteesource.com
Expire-Date: 0
Passphrase: ${keypass}
%commit
%echo done
EOF
)
}

export_keys(){
  local keyname="${1:-${PGP_KEY_NAME:-Gravitee.io Bot}}"
  local keyfilename="${2:-pgpkey}"
  gpg2 --armor --batch --export "${keyname}" > "${keyfilename}.pub"
  gpg2 --armor --batch --export-secret-keys "${keyname}" > "${keyfilename}.key"
}

delete_keys(){
  local fingerprint="${1:-}"
  if [[ -n "${fingerprint}" ]]
  then
    gpg2 --batch --yes --delete-secret-keys "${fingerprint}"
    gpg2 --batch --yes --delete-keys "${fingerprint}"
  else
    while read -r fingerprint
    do
      if gpg2 --list-secret-keys --with-keygrip --with-colons | grep -q "${fingerprint}"
      then
        gpg2 --batch --yes --delete-secret-keys "${fingerprint}"
      fi
    done < <(gpg2 --list-secret-keys --with-keygrip --with-colons | sed -n '/^fpr/{s/^fpr:*\(.*\):$/\1/p}')
    while read -r fingerprint
    do
      if gpg2 --list-keys --with-keygrip --with-colons | grep -q "${fingerprint}"
      then
        gpg2 --batch --yes --delete-keys "${fingerprint}"
      fi
    done < <(gpg2 --list-keys --with-keygrip --with-colons | sed -n '/^fpr/{s/^fpr:*\(.*\):$/\1/p}')
  fi
}

help(){
  local commands
  commands="$(sed -n '/^[a-z].*(){$/ s/(){//p' "${HOME}/utils.sh")"
  cat <<EOF
usage: <command> [command args]
Available commands:
$(echo "${commands}" | sed 's/^/  * /')

Examples:

* generate PGP keys:
generate_pgp_key "SuperME" "Awesome Password or not"

* export keys to files:
export_keys "SuperME" "mykey"

* delete keys:
delete_keys "SuperME"

* delete all keys:
delete_keys

EOF
}
