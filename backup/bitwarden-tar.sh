#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

rclone_conf_path=/path/to/rclone.conf

baseDir="/tmp"

keyPrefix="tar"
tarFilename="bitwarden.tar.gz"
tarFilepath="${baseDir}/${tarFilename}"

if [ -e "${tarFilepath}" ]
then
    rm "${tarFilepath}"
fi

ls /bitwarden/db.sqlite3

tar cvfP "${tarFilepath}" --exclude='/bitwarden/sends/*' --exclude='/bitwarden/attachments/*' --exclude='/bitwarden/icon_cache/*' --exclude='/bitwarden/tmp/*' --exclude='/bitwarden/sends' --exclude='/bitwarden/attachments' --exclude='/bitwarden/icon_cache' --exclude='/bitwarden/tmp' /bitwarden 2>&1

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m --checksum copyto "${tarFilepath}" "bitwarden_aws:$BITWARDEN_AWS_S3_BUCKET/${keyPrefix}/${tarFilename}"

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m --checksum copyto "${tarFilepath}" "bitwarden_oss:$BITWARDEN_OSS_S3_BUCKET/${keyPrefix}/${tarFilename}"

rclone --config $rclone_conf_path --contimeout=3m --timeout=10m --checksum copyto "${tarFilepath}" "bitwarden_cos:$BITWARDEN_COS_S3_BUCKET/${keyPrefix}/${tarFilename}"

rm "${tarFilepath}"