#!/bin/bash

is_defined() {
  local var=${1}
  local msg=${2:-'A required value is missing'}
  local status=${3:-'1'}
  
  if [ -z "${var}" ]; then
    echo "${msg}"
    exit ${status}
  fi
}

is_dir() {
  local path=${1}
  local msg=${2:-'Invalid - not a directory'}
  local status=${3:-'1'}

  if [ ! -d "${path}" ]; then
    echo "${msg}"
    exit ${status}
  fi
}

exists() {
  local path=${1}
  local msg=${2:-'File does not exists'}
  local status=${3:-'1'}

  if [ ! -e "${path}" ]; then
    echo "${msg}"
    exit ${status}
  fi
}

is_executable() {
  local path=${1}
  local msg=${2:-'File is not executable'}
  local status=${3:-'1'}

  if [ ! -x "${path}" ]; then
    echo "${msg}"
    exit ${status}
  fi
}

run_ssh() {
  local hera_ssh_key=${HERA_SSH_KEY}
  local hera_hostname=${HERA_HOSTNAME}
  local hera_username=${HERA_USERNAME}

  local ssh_options="-o StrictHostKeyChecking=no ${HERA_SSH_OPTIONS}"

# to impl  
#  if [ -n "${hera_ssh_key}" ]; then
#    exists "${hera_ssh_key}" "Provided path to SSH_KEY does not exists: ${hera_ssh_key}." 667
#  fi
  is_defined "${hera_hostname}" 'Please define env var HERA_HOSTNAME.' 668
  is_defined "${hera_username}" 'Please define env var HERA_USERNAME' 669

  ssh ${ssh_options} \
      "${hera_username}@${hera_hostname}"\
      "${@}"
}
