#!/bin/bash

readonly WRAPPED_SCRIPT=${BUILD_SCRIPT:-'1'}
readonly HARMONIA_HOME=${HARMONIA_HOME:-"${WORKSPACE}/harmonia/"}
readonly HERA_HOME=${HERA_HOME:-"${WORKSPACE}/hera/"}

export MAVEN_VERBOSE="-X"

echo "WORKSPACE: ${WORKSPACE}"
echo "HERA_HOME: ${HERA_HOME}"

source "${HERA_HOME}/library.sh"

for var in "${HARMONIA_HOME}" "${HERA_HOME}" "${WORKSPACE}" "${MAVEN_HOME}" "${JAVA_HOME}"
do
  is_defined "${var}" 'One of the HOME value or WORKSPACE is undefined'
  is_dir "${var}" 'One of the HOME or the WORKSPACE is not a dir'
done
is_defined "${JOB_NAME}" 'No BUILD_NAME provided'
is_defined "${BUILD_ID}" 'No BUILD_ID provided'

echo "JOB_NAME: ${JOB_NAME}"
echo "BUILD_ID: ${BUILD_ID}"
echo "HARMONIA_HOME: ${HARMONIA_HOME}"
echo "JAVA_HOME: ${JAVA_HOME}"
echo "MAVEN_HOME: ${MAVEN_HOME}"
echo "MAVEN_OPTS: ${MAVEN_OPTS}"
echo "MAVEN_VERBOSE: ${MAVEN_VERBOSE}"
cd "${WORKSPACE}"

git config --global url."https://".insteadOf git:/
"${HARMONIA_HOME}/eap-job.sh" | tee "${HERA_HOME}/build_${BUILD_ID}.log"
readonly BUILD_STATUS="${PIPESTATUS[0]}"
echo "${BUILD_STATUS}" > "${HERA_HOME}/build_${BUILD_ID}_${BUILD_STATUS}.result"
exit "${BUILD_STATUS}"
