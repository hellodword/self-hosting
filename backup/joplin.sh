#! /bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

rclone_conf_path=/path/to/rclone.conf
bark_path=/path/to/bark.sh

local_path=/tmp/joplin
output="$(rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync joplin_cos:$JOPLIN_COS_S3_BUCKET $local_path 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash $bark_path "joplin error"   "joplin sync to local error"   "$output" "minuet"
fi


i=0

# backup script
((i++))
output="$(rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync $local_path joplin_oss:$JOPLIN_OSS_S3_BUCKET 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash $bark_path "joplin error"   "joplin sync to oss error"   "$output" "minuet"
else
    ((i--))
fi

((i++))
output="$(rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync $local_path joplin_aws:$JOPLIN_AWS_S3_BUCKET 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash $bark_path "joplin error"   "joplin sync to aws error"   "$output" "minuet"
else
    ((i--))
fi

((i++))
output="$(rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync $local_path joplin_b2:$JOPLIN_B2_BUCKET 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash $bark_path "joplin error"   "joplin sync to b2 error"   "$output" "minuet"
else
    ((i--))
fi


if ((i==0)); then
    bash $bark_path "joplin success" "joplin sync success"       "ok"      "silence"
fi
