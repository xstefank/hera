#!/bin/bash
set -eo pipefail

set +u
readonly BUILD_ID=${BUILD_ID}
readonly PRINT_BUILD_ENV=${PRINT_BUILD_ENV:-'true'}
readonly MAVEN_SETTINGS_XML=${MAVEN_SETTINGS_XML:-'/opt/tools/settings.xml'}
readonly MAVEN_GOALS=${MAVEN_GOALS:-'clean install'}
set -u

readonly HERA_HOME=${HERA_HOME:-"${WORKSPACE}/hera/"}
readonly FAIL_TO_SET_DEFAULT_TO_WORKSPACE_CODE='13'

printJobConfig() {
  set +u
  echo "JOB_NAME: ${JOB_NAME}"
  echo "BUILD_ID: ${BUILD_ID}"
  echo "JAVA_HOME: ${JAVA_HOME}"
  echo "MAVEN_HOME: ${MAVEN_HOME}"
  echo "MAVEN_OPTS: ${MAVEN_OPTS}"
  echo "MAVEN_SETTINGS_XML: ${MAVEN_SETTINGS_XML}"
  echo "MAVEN_VERBOSE: ${MAVEN_VERBOSE}"
  echo "MAVEN_GOALS: ${MAVEN_GOALS}"
  set -u
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

readonly HOSTNAME=${HOSTNAME:-'localhost'}
export HOSTNAME

for var in "${HERA_HOME}" "${WORKSPACE}" "${MAVEN_HOME}" "${JAVA_HOME}"
do
  is_defined "${var}" 'One of the HOME value or WORKSPACE is undefined'
  is_dir "${var}" 'One of the HOME or the WORKSPACE is not a dir'
done
is_defined "${JOB_NAME}" 'No BUILD_NAME provided'
is_defined "${BUILD_ID}" 'No BUILD_ID provided'

printJobConfig

cd "${WORKSPACE}" || exit "${FAIL_TO_SET_DEFAULT_TO_WORKSPACE_CODE}"

export USER='jenkins'
printEnv
if [ -n "${MAVEN_SETTINGS_XML}" ]; then
  readonly MAVEN_SETTINGS_OPT="-s ${MAVEN_SETTINGS_XML}"
else
  readonly MAVEN_SETTINGS_OPT=""
fi


echo '==== Executing Maven ==='
echo "Cmd: # ${MAVEN_HOME}/bin/mvn ${MAVEN_SETTINGS_OPT} ${MAVEN_OPTS} ${MAVEN_GOALS}"
${MAVEN_HOME}/bin/mvn ${MAVEN_SETTINGS_OPT} ${MAVEN_OPTS} ${MAVEN_GOALS}
