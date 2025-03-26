#!/usr/bin/env bash
set -euo pipefail

source "${HOME}/utils.sh"

COMMANDS="$(sed -n '/^[a-z].*(){$/ s/(){//p' "${HOME}/utils.sh")"

### if argument is provided, and its about getting a shell
if [[ "${1:-noop}" =~ ^.*/?(bash|sh)$ ]]
then
  exec "$@"
### if argument is provided, and its a list of utils commands
elif [[ -n "$*" ]] && for command in "$@"; do printf '%s\0' "${COMMANDS}" | grep -qwz "${command}"; done
then
  for command in "$@"
  do
    "${command}"
  done
### if argument is provided, blindly execute it
elif [[ -n "$*" ]]
then
  "$@"
# default scenario, setup everything and sign rpms
else
  scenario_sign_rpm
fi
