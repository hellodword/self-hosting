#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

keyPrefix="sync"
dirPath="/bitwarden"

ls "${dirPath}/db.sqlite3"

rclone --config /path/to/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_aws:$BITWARDEN_AWS_S3_BUCKET/${keyPrefix}"

rclone --config /path/to/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_oss:$BITWARDEN_OSS_S3_BUCKET/${keyPrefix}"

rclone --config /path/to/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_cos:$BITWARDEN_COS_S3_BUCKET/${keyPrefix}"
