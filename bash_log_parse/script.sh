#!/bin/bash

echo -e "Longest Time Response\n"
grep -E 'Started|Completed' ./logfile.log | while read -r line; do
  if [[ $line == *"Started"* ]]; then
    req="$line"
  elif [[ $line == *"Completed"* && $line =~ in\ ([0-9]+)ms ]]; then
    time=${BASH_REMATCH[1]}
    echo "$time $req @ $line"
  fi
done | sort -nr | head -n1 | cut -d' ' -f2- | sed 's/ @ /\n/'

echo -e "\nUnique Endpoints Response\n"
grep 'Started' ./logfile.log | cut -d'"' -f2 | sed 's/\?.*//' | sort | uniq -c | sort -nr

