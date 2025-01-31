#!/bin/bash

echo -e "Longest Time Response\n"
awk '/Started/ {req=$0} 
    /Completed/ {if ($0 ~ /in ([0-9]+)ms/) {
        split($0, arr, "in "); 
        split(arr[2], time, "ms"); 
        print time[1], req, "@", $0}
    }' ./logfile.log | sort -nr | head -n1 | cut -d' ' -f2- | sed 's/ @ /\n/'


echo -e "\nUnique Endpoints Response\n"
grep 'Started' ./logfile.log | cut -d'"' -f2 | sed 's/\?.*//' | sort | uniq -c | sort -nr

