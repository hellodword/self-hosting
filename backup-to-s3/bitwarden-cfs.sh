#!/bin/bash

set -e

baseDir="/tmp"

keyPrefix="bitwarden/$(date +"%Y%m%d")"
tarFilename="bitwarden-$(date +"%Y%m%d%H%M%S").tar.gz"
tarFilepath="${baseDir}/${tarFilename}"


tar cvfP "${tarFilepath}" --exclude='/mnt/sends/*' --exclude='/mnt/attachments/*' --exclude='/mnt/icon_cache/*' --exclude='/mnt/tmp/*' --exclude='/mnt/sends' --exclude='/mnt/attachments' --exclude='/mnt/icon_cache' --exclude='/mnt/tmp' /mnt 2>&1

./s3uploader -prefix "COS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 30 2>&1

./s3uploader -prefix "OSS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 30 2>&1

./s3uploader -prefix "AWS_" -key "${keyPrefix}/${tarFilename}" -path "${tarFilepath}" -timeout 120 2>&1
