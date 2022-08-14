#! /bin/bash

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

# backup script
output="$(rclone --config /path/to/rclone.conf --contimeout=3m --timeout=10m sync joplin_cos:$JOPLIN_COS_S3_BUCKET joplin_oss:$JOPLIN_OSS_S3_BUCKET 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "joplin error"   "joplin sync to oss error"   "$output" "minuet"
else
    bash /path/to/bark.sh "joplin success" "joplin sync to oss success" "ok"      "silence"
fi

output="$(rclone --config /path/to/rclone.conf --contimeout=3m --timeout=10m sync joplin_cos:$JOPLIN_COS_S3_BUCKET joplin_aws:$JOPLIN_AWS_S3_BUCKET 2>&1)" || exit_code=$?
if [ "$exit_code" != "" ]; then
    bash /path/to/bark.sh "joplin error"   "joplin sync to aws error"   "$output" "minuet"
else
    bash /path/to/bark.sh "joplin success" "joplin sync to aws success" "ok"      "silence"
fi