#!/bin/bash
set +u
readonly HERA_SSH_KEY=${HERA_SSH_KEY}
readonly HERA_HOSTNAME=${HERA_HOSTNAME}
readonly HERA_USERNAME=${HERA_USERNAME}
readonly HERA_SSH_OPTIONS=${HERA_SSH_OPTIONS}
readonly BUILD_ID=${BUILD_ID}
readonly JOB_NAME=${JOB_NAME}
set -u

is_defined() {
  local var
  local msg
  local status

  var=${1}
  msg=${2:-'A required value is missing'}
  status=${3:-'1'}

  if [ -z "${var}" ]; then
    echo "${msg}"
    exit "${status}"
  fi
}

is_dir() {
  local path
  local msg
  local status

  path=${1}
  msg=${2:-'Invalid - not a directory'}
  status=${3:-'1'}

  if [ ! -d "${path}" ]; then
    echo "${msg}"
    exit "${status}"
  fi
}

exists() {
  local path
  local msg
  local status

  path=${1}
  msg=${2:-'File does not exists'}
  status=${3:-'1'}

  if [ ! -e "${path}" ]; then
    echo "${msg}"
    exit "${status}"
  fi
}

is_executable() {
  local path
  local msg
  local status

  path=${1}
  msg=${2:-'File is not executable'}
  status=${3:-'1'}

  if [ ! -x "${path}" ]; then
    echo "${msg}"
    exit "${status}"
  fi
}

run_ssh() {
  local ssh_options

  ssh_options="-o StrictHostKeyChecking=no ${HERA_SSH_OPTIONS}"

  if [ -n "${HERA_SSH_KEY}" ]; then
    exists "${HERA_SSH_KEY}" "Provided path to SSH_KEY does not exists: ${HERA_SSH_KEY}." 667
    ssh_options="${ssh_options} -i ${HERA_SSH_KEY}"
  fi

  is_defined "${HERA_HOSTNAME}" 'Please define env var HERA_HOSTNAME.' 668
  is_defined "${HERA_USERNAME}" 'Please define env var HERA_USERNAME' 669

  # shellcheck disable=SC2086,SC2029
  ssh ${ssh_options} \
      "${HERA_USERNAME}@${HERA_HOSTNAME}"\
      "${@}"
}
