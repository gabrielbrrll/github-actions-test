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

REPORT_DIR="${BASE_DIR}"
REPORT_FILE="index.json"

# make sure report dir exists
mkdir -p "${REPORT_DIR}"
touch "${REPORT_DIR}/${REPORT_FILE}"

function generate_report(){
  local full_report=""
  local limit=3
  local total_fails=`cat ${REPORT_FILE} | jq ".stats.failures"`
  local fail_results=`cat $REPORT_FILE | jq -r '[.results[].suites[].tests[] | select(.fail == true)']`
  local cypress_run_id=$(echo "${{ steps.run-integration.outputs.dashboardUrl }}" | sed 's:.*/::')
  for result in $(echo "${fail_results}" | jq -r '.[] | @base64'); do
    _jq() {
      echo ${result} | base64 --decode | jq -r ${1}
    }
    title=$(_jq '.title')
    parentId=$(_jq '.parentUUID')
    echo ${parentId}
    echo "$file FILE PATHTHTHT"
    message=$(_jq '.err.message')
    report=$(echo ":test_tube:*TEST*: $title \n:open_file_folder:*FILE*: <https://cypress-dashboard.staging.manabie.io:31600/run/$cypress_run_id | $file> \n:speech_balloon:*MESSAGE*: $message \n\n")
    full_report+="$report"
    if [[ $limit -eq 0 ]]; then
      break
    fi
    ((limit--))
    full_report=$(echo ${full_report//$'\n'/'%0A'} | sed 's/"//g')
    echo "::set-output name=fail_count::$total_fails"
    echo "::set-output name=fail_report::$full_report"
  done
}

pushd "${REPORT_DIR}"
  generate_report
popd 
