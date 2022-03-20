m#!/bin/bash

if [ -f "index.json" ] 
  then
    full_report=""
    limit=3
    failures=`cat index.json | jq ".stats.failures"`
    jq -c '.results[].suites[]' index.json | while read -r i && [[ "$limit" != 0 ]]; do
      fail_count=$(echo "$i" | jq '.failures | length')
      if [[ $fail_count -gt 0 ]]; then
        ((limit--))
        title=$(echo "$i" | jq '.tests[0].title')
        file=$(echo "$i" | jq '.fullFile')
        message=$(echo "$i" | jq '.tests[0].err.message')
        run_id=$(echo "$i" | jq '.uuid')
        report=$(echo "$fail_count FAIL ARRAY :test_tube:*TEST*: $title \n:open_file_folder:*FILE*: <https://cypress-dashboard.staging.manabie.io:31600/instance/$run_id | $file> \n:speech_balloon:*MESSAGE*: $message \n")
        full_report+="$report \n"
        if [[ $limit == 0 ]]; then
            full_report+="...showing 3 of ${failures} test fails"
        fi
      fi
      full_report=$(echo ${full_report//$'\n'/'%0A'} | sed 's/"//g')
      echo "::set-output name=fail_count::"${failures}""
      echo "::set-output name=fail_report::"${full_report}""
    done
  else
    echo "No failed"
fi
