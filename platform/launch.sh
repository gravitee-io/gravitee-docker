#!/bin/bash
#
# Copyright (C) 2015 The Gravitee team (http://gravitee.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

readonly WORKDIR="$HOME/graviteeio-api-platform"
readonly DIRNAME=$(dirname $0)
readonly PROGNAME=$(basename $0)
readonly color_title='\033[32m'
readonly color_text='\033[1;36m'

# OS specific support (must be 'true' or 'false').
declare cygwin=false
declare darwin=false
declare linux=false
declare dc_exec="docker-compose up"
declare apim_version="latest"
declare am_version="latest"
declare am_mgt_api_base=""

optspec=":h-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
    -)
        case "${OPTARG}" in
        am_version=*)
            am_version=${OPTARG#*=}
            ;;
        apim_version=*)
            apim_version=${OPTARG#*=}
            ;;
        version=*)
            am_version=${OPTARG#*=}
            apim_version=${OPTARG#*=}
            ;;
        *)
            if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                echo "Unknown option --${OPTARG}" >&2
            fi
            ;;
        esac
        ;;
    h)
        echo "usage: $0 [-v] [--version[=]<value>]" >&2
        echo "usage: $0 [-v] [--am_version[=]<value>] [--apim_version[=]<value>]" >&2

        exit 2
        ;;
    *)
        if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
            echo "Non-option argument: '-${OPTARG}'" >&2
        fi
        ;;
    esac
done

echo "Running Gravitee platform"
echo "APIM version: ${apim_version}"
echo "AM version: ${am_version}"

if [[ $am_version == nightly ]] || [[ $am_version == 3.* ]]; then
    am_mgt_api_base="\/"
fi

dc_exec="APIM_VERSION=${apim_version} AM_VERSION=${am_version} AM_MGT_API_BASE=${am_mgt_api_base} ${dc_exec}"

welcome() {
    echo
    echo -e " ${color_title}   _____                 _ _              _                                 \033[0m"
    echo -e " ${color_title}  / ____|               (_) |            (_)                                \033[0m"
    echo -e " ${color_title} | |  __ _ __ __ ___   ___| |_ ___  ___   _  ___                            \033[0m"
    echo -e " ${color_title} | | |_ |  __/ _  \ \ / / | __/ _ \/ _ \ | |/ _ \                           \033[0m"
    echo -e " ${color_title} | |__| | | | (_| |\ V /| | ||  __/  __/_| | (_) |                          \033[0m"
    echo -e " ${color_title}  \_____|_|  \__,_| \_/ |_|\__\___|\___(_)_|\___/                           \033[0m"
    echo -e " ${color_title}                         \033[0m${color_text}http://gravitee.io\033[0m"
    echo -e " ${color_title}                                                                            \033[0m"
    echo -e " ${color_title}                 _____ _____    _____  _       _    __                      \033[0m"
    echo -e " ${color_title}           /\   |  __ \_   _|  |  __ \| |     | |  / _|                     \033[0m"
    echo -e " ${color_title}          /  \  | |__) || |    | |__) | | __ _| |_| |_ ___  _ __ _ __ ___   \033[0m"
    echo -e " ${color_title}         / /\ \ |  ___/ | |    |  ___/| |/ _  | __|  _/ _ \|  __|  _   _ \  \033[0m"
    echo -e " ${color_title}        / ____ \| |    _| |_   | |    | | (_| | |_| || (_) | |  | | | | | | \033[0m"
    echo -e " ${color_title}       /_/    \_\_|   |_____|  |_|    |_|\__,_|\__|_| \___/|_|  |_| |_| |_| \033[0m"
    echo -e " ${color_title}                                                                            \033[0m"

    echo
}

init_env() {
    local dockergrp
    # define env
    case "$(uname)" in
    CYGWIN*)
        cygwin=true
        ;;

    Darwin*)
        darwin=true
        ;;

    Linux)
        linux=true
        ;;
    esac

    # test if docker must be run with sudo
    dockergrp=$(groups | grep -c docker)
    if [[ $darwin == false && $dockergrp == 0 ]]; then
        dc_exec="sudo $dc_exec"
    fi
}

main() {
    welcome
    init_env

    if [[ $? != 0 ]]; then
        exit 1
    fi
    set -e
    mkdir -p "$WORKDIR"
    pushd $WORKDIR > /dev/null
        echo "Download required files ..."
        mkdir -p traefik/certs ; mkdir -p traefik/config ; mkdir -p mongo/docker-entrypoint-initdb.d ; mkdir -p gravitee
        curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/docker-compose.yml -o "docker-compose.yml"
        cd mongo/docker-entrypoint-initdb.d && { curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/mongo/docker-entrypoint-initdb.d/create-index.js -o "create-index.js" ; cd -; }
        cd traefik/certs && { curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/traefik/certs/gio-selfsigned.crt -o "gio-selfsigned.crt" ; cd -; }
        cd traefik/certs && { curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/traefik/certs/gio-selfsigned.key -o "gio-selfsigned.key" ; cd -; }
        cd traefik/config && { curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/traefik/config/traefik.toml -o "traefik.toml" ; cd -; }
        cd gravitee && { curl -Lf https://raw.githubusercontent.com/gravitee-io/gravitee-docker/master/platform/gravitee/cacerts -o "cacerts" ; cd -; }
        echo
        echo "Launch Gravitee.io API Platform..."
        eval ${dc_exec}
    popd > /dev/null
}

main
