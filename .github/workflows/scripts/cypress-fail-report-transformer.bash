#!/bin/bash

if [ -f "index.json" ] 
  then
  full_report=""
  limit=3
  
  failures=`cat index.json | jq ".stats.failures"`
  
  jq -c '.results[].suites[]' index.json | while read -r i && [[ $limit != 0 ]]; do
    title=$(echo "$i" | jq '.tests[0].title')
    file=$(echo "$i" | jq '.fullFile')
    message=$(echo "$i" | jq '.tests[0].err.message')
    run_id=$(echo "$i" | jq '.uuid')
    
    echo "$fail_count +++FAIL COUNT"
    
    if [[ $fail_count -gt 1 ]]; then
        title+=" (showing 1 out of $fail_count tests failing"
    fi
    
    report=$(echo ":test_tube:*TEST*: $title \n:open_file_folder:*FILE*: <https://cypress-dashboard.staging.manabie.io:31600/instance/$run_id | $file> \n:speech_balloon:*MESSAGE*: $message \n")
    
    if [[ $fail_count -gt 0]]; then
        full_report+="$report /n"
        ((limit--))
    fi
    
    if [ $limit == 0 ]; then
        full_report+="...showing 3 of ${failures} test suite fails"
    fi
    
    full_report=$(echo ${full_report//$'\n'/'%0A'} | sed 's/"//g')
    echo "::set-output name=fail_count::$failures"
    echo "::set-output name=fail_report::$full_report"
  done
  else
      echo "No Failed Tests"
  fi
