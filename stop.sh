#!/bin/bash
source "${HERA_HOME}/library.sh"

is_defined "${CID}" "No container ID provided"
is_cid_running=$(run_ssh "podman ps --filter=id=${CID} | sed -e /CONTAIN/d | wc -l")
if [ ${is_cid_running} -gt 0 ]; then
  run_ssh "podman stop ${CID}"
fi
