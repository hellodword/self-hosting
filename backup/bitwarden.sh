#! /bin/bash

# backup script
output="$(bash /path/to/bitwarden-sync.sh 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "bitwarden error"   "bitwarden sync error"   "$output" "minuet"
else
    bash /path/to/bark.sh "bitwarden success" "bitwarden sync success" "ok"      "silence"
fi

output="$(bash /path/to/bitwarden-tar.sh 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "bitwarden error"   "bitwarden tar error"   "$output" "minuet"
else
    bash /path/to/bark.sh "bitwarden success" "bitwarden tar success" "ok"      "silence"
fi