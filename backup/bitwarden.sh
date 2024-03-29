#! /bin/bash

TRIGGER_TYPE="$1"

i=0

# backup script
# ((i++))
# output="$(/usr/local/etc/backup/bitwarden-sync.sh 2>&1)" || exit_code=$?
# if [ "$exit_code" != "" ]; then
#     /usr/local/etc/notify/bark.sh "bitwarden error"   "bitwarden $TRIGGER_TYPE sync error"   "$output" "minuet"
# else
#     ((i--))
# fi

((i++))
/usr/local/etc/backup/bitwarden-git.sh || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /usr/local/etc/notify/bark.sh "bitwarden error"   "bitwarden $TRIGGER_TYPE git error"   "secret" "minuet"
else
    ((i--))
fi


if ((i==0)); then
    bash /usr/local/etc/notify/bark.sh "bitwarden success" "bitwarden $TRIGGER_TYPE success"     "ok"      "silence"
fi
