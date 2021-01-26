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

is_defined "${CID}" 'No contained id provided' 1
is_defined "${BUILD_SCRIPT}" 'No build script provided' 2

readonly SHORT_CID=$(echo "${CID}" | sed -e 's/\(^......\).*$/\1/')

dumpBuildEnv "${HERA_HOME}/build-env.sh"

run_ssh "podman exec \
		-e JOB_NAME="${JOB_NAME}" \
		-e WORKSPACE="${WORKSPACE}" \
		-e JAVA_HOME="${JAVA_HOME}" \
		-e MAVEN_HOME="${MAVEN_HOME}" \
		-e MAVEN_OPTS='"${MAVEN_OPTS}"' \
		-e BUILD_ID="${BUILD_ID}" \
		-e MAVEN_SETTINGS_XML="${MAVEN_SETTINGS_XML}" \
		-ti ${SHORT_CID} '${BUILD_SCRIPT}' ${@}"
