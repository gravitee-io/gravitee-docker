#!/bin/bash

declare -A images
readonly REPO=graviteeio

build() {
    for dir in "${!images[@]}"; do
        echo "image: ${images["$dir"]}"
        pushd "$dir"
            docker build --no-cache -t ${images["$dir"]} .
        popd
    done
}
#images+=(["./base/httpd"]="${REPO}/httpd:latest")
images+=(["./base/java"]="${REPO}/java:8u45")
build
#images=(["./mongodb"]="${REPO}/mongodb:latest")
#images+=(["./management-ui"]="${REPO}/management-ui:latest")
images=(["./management-api"]="${REPO}/management-api:latest")
#images+=(["./kibana3"]="${REPO}/kibana3:latest")
images+=(["./gateway"]="${REPO}/gateway:latest")
images+=(["./elasticsearch"]="${REPO}/elasticsearch:latest")
#images+=(["./api-sample"]="${REPO}/api-sample:latest")
build
