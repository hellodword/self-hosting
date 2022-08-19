#! /bin/bash

TRIGGER_TYPE=" $1"

i=0

# backup script
((i++))
output="$(bash /path/to/bitwarden-sync.sh 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "bitwarden error"   "bitwarden$TRIGGER_TYPE sync error"   "$output" "minuet"
else
    ((i--))
fi

((i++))
output="$(bash /path/to/bitwarden-tar.sh 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "bitwarden error"   "bitwarden$TRIGGER_TYPE tar error"   "$output" "minuet"
else
    ((i--))
fi


if ((i==0)); then
    bash /path/to/bark.sh "bitwarden success" "bitwarden$TRIGGER_TYPE success"     "ok"      "silence"
fi
