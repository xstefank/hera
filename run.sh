#!/bin/bash
set +u
readonly PARENT_JOB_VOLUME=${PARENT_JOB_VOLUME}
readonly BUILD_PODMAN_IMAGE=${BUILD_PODMAN_IMAGE:-'localhost/automatons'}
readonly CONTAINER_USER=${CONTAINER_USER:-'jenkins'}
readonly JENKINS_HOME_DIR=${JENKINS_HOME_DIR:-'/home/jenkins/'}
readonly JOB_NAME=${JOB_NAME}
readonly BUILD_ID=${BUILD_ID}
set -u

add_parent_volume_if_provided() {
  if [ -n "${PARENT_JOB_VOLUME}" ]; then
    echo "-v '${PARENT_JOB_VOLUME}:/parent_job/:ro'"
  fi
}

# shellcheck source=./library.sh
source "${HERA_HOME}"/library.sh

is_defined "${WORKSPACE}" "No WORKSPACE provided." 1
is_dir "${WORKSPACE}" "Workspace provided is not a dir: ${WORKSPACE}" 2
is_defined "${JOB_NAME}" "No JOB_NAME provided." 3
is_defined "${BUILD_ID}" "No BUILD_ID provided." 4

readonly CONTAINER_TO_RUN_NAME=${CONTAINER_TO_RUN_NAME:-$(container_name "${JOB_NAME}" "${BUILD_ID}")}
readonly CONTAINER_COMMAND=${CONTAINER_COMMAND:-"${WORKSPACE}/hera/wait.sh"}

# shellcheck disable=SC2016
run_ssh "podman run \
            --name "${CONTAINER_TO_RUN_NAME}" \
             --add-host=olympus:192.168.0.11 \
            --rm $(add_parent_volume_if_provided) \
             -u "${CONTAINER_USER}" --userns=keep-id \
            --workdir ${JENKINS_HOME_DIR}/jobs/${JOB_NAME}/workspace \
            -v ${JENKINS_HOME_DIR}/jobs/${JOB_NAME}:$(dirname "${WORKSPACE}"):rw \
            -v /opt/:/opt/:ro \
	        -d ${BUILD_PODMAN_IMAGE} '${CONTAINER_COMMAND}'"
