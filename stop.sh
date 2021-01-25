#!/bin/bash
set -euo pipefail

# shellcheck source=library.sh
source "${HERA_HOME}"/library.sh

is_defined "${CID}" "No container ID provided"
run_ssh "podman stop -i ${CID}"
