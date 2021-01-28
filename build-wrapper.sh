#!/bin/bash
set -eo pipefail

set +u
readonly BUILD_COMMAND=${BUILD_COMMAND}
readonly BUILD_ID=${BUILD_ID}
readonly PRINT_BUILD_ENV=${PRINT_BUILD_ENV}
readonly HARMONIA_DEBUG=${HARMONIA_DEBUG}
readonly MAVEN_VERBOSE=${MAVEN_VERBOSE}
set -u

readonly PARENT_JOB_DIR='/parent_job/'
readonly HARMONIA_HOME=${HARMONIA_HOME:-"${WORKSPACE}/harmonia/"}
readonly HERA_HOME=${HERA_HOME:-"${WORKSPACE}/hera/"}

readonly FAIL_TO_SET_DEFAULT_TO_WORKSPACE_CODE='13'

printJobConfig() {
  echo "JOB_NAME: ${JOB_NAME}"
  echo "BUILD_ID: ${BUILD_ID}"
  echo "HARMONIA_HOME: ${HARMONIA_HOME}"
  echo "JAVA_HOME: ${JAVA_HOME}"
  echo "MAVEN_HOME: ${MAVEN_HOME}"
  echo "MAVEN_OPTS: ${MAVEN_OPTS}"
  echo "MAVEN_VERBOSE: ${MAVEN_VERBOSE}"
  echo "BUILD_COMMAND: ${BUILD_COMMAND}"
  echo "TEST_TO_RUN: ${TEST_TO_RUN}"
  echo "RERUN_FAILING_TESTS: ${RERUN_FAILING_TESTS}"
}

printEnv() {
  if [ -n "${PRINT_BUILD_ENV}" ]; then
    echo "=== ${JOB_NAME} (Build #${BUILD_ID} environnement ==="
    env
    echo '===================================================='
  fi
}

echo "WORKSPACE: ${WORKSPACE}"
echo "HERA_HOME: ${HERA_HOME}"

# shellcheck source=./library.sh
source "${HERA_HOME}/library.sh"

copy_artefact_from_parent_job() {
  local parent_job_dir="${1}"
  local workspace=${WORKSPACE:-${2}}

  is_defined "${parent_job_dir}"
  is_dir "${parent_job_dir}"

  echo "parent_job_dir: ${parent_job_dir}"
  echo "Copying artefacts from ${parent_job_dir} to ${workspace}"
  echo -n ' - starting copy at: '
  date +%T
  echo '...'
  rsync -ar --exclude hera/ --exclude harmonia/ "${parent_job_dir}" "${workspace}"
  echo "Done (at $(date +%T))"
  echo 'check if required test dependency are available'
  find "${workspace}" -name '*wildfly-testsuite-shared*' -type d
}

readonly HOSTNAME=${HOSTNAME:-'localhost'}
export HOSTNAME

for var in "${HARMONIA_HOME}" "${HERA_HOME}" "${WORKSPACE}" "${MAVEN_HOME}" "${JAVA_HOME}"
do
  is_defined "${var}" 'One of the HOME value or WORKSPACE is undefined'
  is_dir "${var}" 'One of the HOME or the WORKSPACE is not a dir'
done
is_defined "${JOB_NAME}" 'No BUILD_NAME provided'
is_defined "${BUILD_ID}" 'No BUILD_ID provided'
is_defined "${BUILD_COMMAND}" 'No BUILD_COMMAND provided.'

printJobConfig

cd "${WORKSPACE}/workdir" || exit "${FAIL_TO_SET_DEFAULT_TO_WORKSPACE_CODE}"

printEnv

if [ "${BUILD_COMMAND}" = 'testsuite' ]; then
  copy_artefact_from_parent_job "${PARENT_JOB_DIR}" "${WORKSPACE}"
fi

if [ "${HARMONIA_DEBUG}" ]; then
  bash -x "${HARMONIA_HOME}/eap-job.sh" ${BUILD_COMMAND} 2>&1 | tee "${HERA_HOME}/build_${BUILD_ID}.log"
else
  "${HARMONIA_HOME}/eap-job.sh" ${BUILD_COMMAND} 2>&1 | tee "${HERA_HOME}/build_${BUILD_ID}.log"
fi
readonly BUILD_STATUS="${PIPESTATUS[0]}"
echo "${BUILD_STATUS}" > "${HERA_HOME}/build_${BUILD_ID}_${BUILD_STATUS}.result"
exit "${BUILD_STATUS}"
