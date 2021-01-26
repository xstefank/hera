#!/bin/bash
readonly CID=${CID}
readonly HERA_HOME=${HERA_HOME}
set -euo pipefail

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

if [ -z "${CID}" ]; then
  echo "INFO: No CID provided, skipping."
else
  run_ssh "podman stop -i ${CID}"
fi
