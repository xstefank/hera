#!/bin/bash
readonly BUILD_PODMAN_IMAGE=${BUILD_PODMAN_IMAGE:-'fedora'}
readonly VOLUME_HOME='/home/jenkins/workspace'

source ${HERA_HOME}/library.sh

is_defined "${WORKSPACE}" "No workspace provided." 1
is_dir "${WORKSPACE}" "Workspace provided is not a dir: ${WORKSPACE}" 2

readonly CONTAINER_COMMAND=${CONTAINER_COMMAND:-"${WORKSPACE}/hera/wait.sh"}
readonly PROJECT_NAME=$(basename "../${WORKSPACE}")
readonly VOLUME_PATH="${VOLUME_HOME}/${PROJECT_NAME}"

run_ssh "podman run -v "${VOLUME_PATH}:${WORKSPACE}:rw" -d ${BUILD_PODMAN_IMAGE} '${CONTAINER_COMMAND}'"
