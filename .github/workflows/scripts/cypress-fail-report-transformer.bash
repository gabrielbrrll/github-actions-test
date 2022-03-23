#!/bin/bash

set -eu

# Use this env var to represent workspace dir on CI
GITHUB_WORKSPACE=${GITHUB_WORKSPACE:-}

# use this instead to represent workspace dir for local environment
if [ "${GITHUB_WORKSPACE}" == "" ]; then
  BASE_DIR=$(cd $(dirname $0)/../..; pwd)
else
  BASE_DIR="${GITHUB_WORKSPACE}"
fi

REPORT_DIR="${BASE_DIR}/"
REPORT_FILE="index.json"

# make sure report dir exists
mkdir -p "${REPORT_DIR}"
touch "${REPORT_DIR}/${REPORT_FILE}"

function generate_report(){
  local full_report=""
  local limit=0
  local failures=`cat ${REPORT_FILE} | jq ".stats.failures"`
  local total_fails=`cat ${REPORT_FILE} | jq ".stats.failures"`
  local fail_results=`cat $REPORT_FILE | jq -r '[.results[].suites[] | select(.failures | length > 0)']`
  local cypress_run_id=$(echo "${{ steps.run-integration.outputs.dashboardUrl }}" | sed 's:.*/::')
  for result in $(echo "${fail_results}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${result} | base64 --decode | jq -r ${1}
    }
    title=$(_jq '.tests[0].title')
    echo $title
  done
}

pushd "${REPORT_DIR}"
  generate_report
popd
