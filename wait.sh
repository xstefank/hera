#!/bin/bash
readonly BUILD_JOB_TIMEOUT=${BUILD_JOB_TIMEOUT:-'18000'}
readonly PAUSE_LENGTH=${PAUSE_LENGTH:-'1'}

echo "Wait for ${BUILD_JOB_TIMEOUT}."
echo -n ''
count=${BUILD_JOB_TIMEOUT}
while [ "${count}" -gt 0 ];
  count=$(expr "${count}" '-' "${PAUSE_LENGTH}")
do
  echo -n '.'
  sleep "${PAUSE_LENGTH}"
done
