#!/bin/bash
readonly CID=${1}
readonly BUILD_SCRIPT=${2}

source "${HERA_HOME}/library.sh"

is_defined "${CID}" 'No contained id provided' 1
is_defined "${BUILD_SCRIPT}" 'No build script provided' 2

run_ssh "podman exec -ti "${CID}" "${BUILD_SCRIPT}"

