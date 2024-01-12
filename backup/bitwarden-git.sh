#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

COMMIT_MSG="$(date '+%Y-%m-%d %H:%M:%S')"
keyPrefix="git-sync"
dirPath="/var/lib/inotifywait-backup/bitwarden"

cd "$dirPath"
git status
# should init and config manually
# # how?
# # sudo systemd-run --pty -p DynamicUser=true -p Environment="PATH=$PATH" -p StateDirectory=inotifywait-backup bash
# mkdir -p "$dirPath"
# git init
# git config user.name bitwarden-backup
# git config user.email backup@bitwarden.com

ls /bitwarden/db.sqlite3
sqlite3 /bitwarden/db.sqlite3 '.backup /tmp/bitwarden.sqlite3'
sqlite3 /tmp/bitwarden.sqlite3 .dump > bitwarden.sql

if [ "$(git status --porcelain | wc -l)" -eq "0" ]; then
    echo "git repo is clean"
else
    git add bitwarden.sql
    git commit -m "$COMMIT_MSG"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_aws:$BITWARDEN_AWS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_oss:$BITWARDEN_OSS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_cos:$BITWARDEN_COS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_b2:$BITWARDEN_B2_BUCKET/${keyPrefix}"
fi
