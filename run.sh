#!/bin/bash
readonly BUILD_PODMAN_IMAGE=${BUILD_PODMAN_IMAGE:-'ubi8-jdk8'}
readonly JENKINS_HOME_DIR=${JENKINS_HOME_DIR:-'/home/jenkins/'}

source ${HERA_HOME}/library.sh

is_defined "${WORKSPACE}" "No WORKSPACE provided." 1
is_dir "${WORKSPACE}" "Workspace provided is not a dir: ${WORKSPACE}" 2
is_defined "${JOB_NAME}" "No JOB_NAME provided." 3

readonly CONTAINER_COMMAND=${CONTAINER_COMMAND:-"${WORKSPACE}/hera/wait.sh"}
readonly VOLUME_PATH="${VOLUME_HOME}/${JOB_NAME}"

run_ssh "podman run -v ${JENKINS_HOME_DIR}/jobs/${JOB_NAME}/workspace:${WORKSPACE}:rw \
	            -v /opt/tools:/opt/tools:ro \
	            -d ${BUILD_PODMAN_IMAGE} '${CONTAINER_COMMAND}'"
