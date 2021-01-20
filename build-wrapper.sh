#!/bin/bash

readonly PARENT_JOB_DIR='/parent_job/'
readonly HARMONIA_HOME=${HARMONIA_HOME:-"${WORKSPACE}/harmonia/"}
readonly HERA_HOME=${HERA_HOME:-"${WORKSPACE}/hera/"}

printEnv() {
  if [ -n "${PRINT_BUILD_ENV}" ]; then
    echo "=== ${JOB_NAME} (Build #${BUIL_ID} environnement ==="
    env
    echo '===================================================='
  fi
}

echo "WORKSPACE: ${WORKSPACE}"
echo "HERA_HOME: ${HERA_HOME}"

source "${HERA_HOME}/library.sh"

readonly HOSTNAME=${HOSTNAME:-'localhost'}
export HOSTNAME

for var in "${HARMONIA_HOME}" "${HERA_HOME}" "${WORKSPACE}" "${MAVEN_HOME}" "${JAVA_HOME}"
do
  is_defined "${var}" 'One of the HOME value or WORKSPACE is undefined'
  is_dir "${var}" 'One of the HOME or the WORKSPACE is not a dir'
done
is_defined "${JOB_NAME}" 'No BUILD_NAME provided'
is_defined "${BUILD_ID}" 'No BUILD_ID provided'

if [ -z "${BUILD_COMMAND}" ]; then
  if [[ "${JOB_NAME}" == *"-testsuite"* ]]; then
    readonly BUILD_COMMAND='testsuite'
  fi
fi

echo "JOB_NAME: ${JOB_NAME}"
echo "BUILD_ID: ${BUILD_ID}"
echo "HARMONIA_HOME: ${HARMONIA_HOME}"
echo "JAVA_HOME: ${JAVA_HOME}"
echo "MAVEN_HOME: ${MAVEN_HOME}"
echo "MAVEN_OPTS: ${MAVEN_OPTS}"
echo "MAVEN_VERBOSE: ${MAVEN_VERBOSE}"
echo "BUILD_COMMAND: ${BUILD_COMMAND}"

cd "${WORKSPACE}"

printEnv

if [ "${BUILD_COMMAND}" = 'testsuite' ]; then
  is_defined "${PARENT_JOB_DIR}"
  is_dir "${PARENT_JOB_DIR}"
  echo "PARENT_JOB_DIR: ${PARENT_JOB_DIR}"
  echo "Copying artefacts from ${PARENT_JOB_DIR} to ${WORKSPACE}"
  echo -n ' - starting copy at: '
  date +%T
  echo '...'
  # could increase perf, but requires to install rsync on automatons
  #rsync -arz "${PARENT_JOB_DIR}" "${WORKSPACE}"
  cp -r "${PARENT_JOB_DIR}" "${WORKSPACE}"
  echo "Done (at $(date +%T))"

fi

readonly HARMONIA_DEBUG=${HARMONIA_DEBUG:-'true'}
if [ "${HARMONIA_DEBUG}" ]; then
  bash -x "${HARMONIA_HOME}/eap-job.sh" ${BUILD_COMMAND} | tee "${HERA_HOME}/build_${BUILD_ID}.log"
else
  "${HARMONIA_HOME}/eap-job.sh" ${BUILD_COMMAND} | tee "${HERA_HOME}/build_${BUILD_ID}.log"
fi
readonly BUILD_STATUS="${PIPESTATUS[0]}"
echo "${BUILD_STATUS}" > "${HERA_HOME}/build_${BUILD_ID}_${BUILD_STATUS}.result"
exit "${BUILD_STATUS}"
