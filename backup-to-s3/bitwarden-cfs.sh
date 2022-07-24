#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

baseDir="/tmp"

keyPrefix="bitwarden/$(date +"%Y%m%d")"
tarFilename="bitwarden-$(date +"%Y%m%d%H%M%S").tar.gz"
tarFilepath="${baseDir}/${tarFilename}"

ls /mnt/bitwarden/db.sqlite3

(cd /mnt && tar cvfP "${tarFilepath}" --exclude='./bitwarden/sends/*' --exclude='./bitwarden/attachments/*' --exclude='./bitwarden/icon_cache/*' --exclude='./bitwarden/tmp/*' --exclude='./bitwarden/sends' --exclude='./bitwarden/attachments' --exclude='./bitwarden/icon_cache' --exclude='./bitwarden/tmp' ./bitwarden 2>&1)

./s3uploader -prefix "COS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 30 2>&1

./s3uploader -prefix "OSS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 30 2>&1

./s3uploader -prefix "AWS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 120 2>&1

rm "${tarFilepath}"