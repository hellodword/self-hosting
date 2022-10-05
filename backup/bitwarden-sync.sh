#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

rclone_conf_path=/path/to/rclone.conf

keyPrefix="sync"
dirPath="/bitwarden"

ls "${dirPath}/db.sqlite3"

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_aws:$BITWARDEN_AWS_S3_BUCKET/${keyPrefix}"

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_oss:$BITWARDEN_OSS_S3_BUCKET/${keyPrefix}"

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_cos:$BITWARDEN_COS_S3_BUCKET/${keyPrefix}"
