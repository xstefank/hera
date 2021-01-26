#!/bin/bash
readonly CID=${CID}
readonly HERA_HOME=${HERA_HOME}
set -euo pipefail

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

is_defined "${CID}" "No container ID provided"
run_ssh "podman stop -i ${CID}"
