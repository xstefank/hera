#!/bin/bash
readonly BUILD_SCRIPT=${BUILD_SCRIPT:-'1'}

source "${HERA_HOME}/library.sh"

is_defined "${CID}" 'No contained id provided' 1
is_defined "${BUILD_SCRIPT}" 'No build script provided' 2

readonly SHORT_CID=$(echo "${CID}" | sed -e 's/\(^......\).*$/\1/')

run_ssh "podman exec ${SHORT_CID} '${BUILD_SCRIPT}'"

