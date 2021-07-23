#!/bin/bash
readonly BUILD_SCRIPT=${BUILD_SCRIPT:-'1'}
shift

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

dumpBuildEnv() {
  local env_dump_file

  env_dump_file=${1}

  is_defined "${env_dump_file}" "No filename provided to store env."

  env | grep -e 'WORKSPACE' -e 'JAVA_HOME' -e 'MAVEN_' | sed -e 's;^;export ;;' > "${env_dump_file}"
  chmod +x "${env_dump_file}"
  if [ "${PIPESTATUS[0]}" -ne "0" ]; then
    echo "Env command failed"
    exit 1
  fi
}

is_defined "${BUILD_SCRIPT}" 'No build script provided' 2

readonly CONTAINER_NAME=$(container_name "${JOB_NAME}" "${BUILD_ID}")

dumpBuildEnv "${HERA_HOME}/build-env.sh"

set +u
run_ssh "podman exec \
        -e JOB_NAME="${JOB_NAME}" \
        -e WORKSPACE="${WORKSPACE}" \
        -e WORKDIR="${WORKDIR}" \
        -e JAVA_HOME="${JAVA_HOME}" \
        -e HARMONIA_SCRIPT="${HARMONIA_SCRIPT}" \
        -e TO_ADDRESS="${TO_ADDRESS}" \
        -e DEBUG="${DEBUG}" \
        -e MAVEN_HOME="${MAVEN_HOME}" \
        -e MAVEN_OPTS='"${MAVEN_OPTS}"' \
        -e MAVEN_GOALS='"${MAVEN_GOALS}"' \
        -e BUILD_ID="${BUILD_ID}" \
        -e BUILD_COMMAND="${BUILD_COMMAND}" \
        -e RERUN_FAILING_TESTS="${RERUN_FAILING_TESTS}" \
        -e MAVEN_SETTINGS_XML="${MAVEN_SETTINGS_XML}" \
        -e PULL_REQUEST_PROCESSOR_HOME="${PULL_REQUEST_PROCESSOR_HOME}" \
        -e VERSION="${VERSION}" \
        -e COMPONENT_UPGRADE_LOGGER="${COMPONENT_UPGRADE_LOGGER}" \
        -e NEXUS_URL=${NEXUS_URL} \
        -e NEXUS_REPO=${NEXUS_REPO} \
        -e NEXUS_CREDENTIALS=${NEXUS_CREDENTIALS} \
        -ti ${CONTAINER_NAME} '${BUILD_SCRIPT}' ${@}"
