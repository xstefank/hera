#!/bin/bash
readonly HERA_HOME=${HERA_HOME:-'./hera'}
export HERA_HOME

source "${HERA_HOME}/library.sh"

is_defined "${HERA_HOME}"
is_dir "${HERA_HOME}"

readonly HERA_CMD=${1}
shift

readonly HERA_SCRIPT=${HERA_HOME}/${HERA_CMD}.sh
exists "${HERA_SCRIPT}" "Invalid command - no script for ${HERA_CMD}"
is_executable "${HERA_SCRIPT}" "Invalid state - script exists, but is not executable : ${HERA_SCRIPT}."

if [ -z "${HERA_DEBUG}" ]; then
  "${HERA_SCRIPT}" ${@}
else
  bash -x "${HERA_SCRIPT}" ${@}
fi
