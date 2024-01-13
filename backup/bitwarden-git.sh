#!/bin/bash

set -e
set -x

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

COMMIT_MSG="$(date '+%Y-%m-%d %H:%M:%S')"
keyPrefix="git-sync"
dirPath="/var/lib/inotifywait-backup/bitwarden"

cd "$dirPath"
git config --global --add safe.directory "$dirPath"
git config --global --add safe.directory /var/lib/private/inotifywait-backup/bitwarden
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


if [ "$(git diff -U0 | wc -l)" -ne "0" ]; then
    ALL_DIFF="$(git diff -U0  | grep '^[+-]' | grep -Ev '^(--- a/|\+\+\+ b/)' )"
    ALL_DIFF_LINE1="$(echo "$ALL_DIFF" | sed -n '1p')"
    ALL_DIFF_LINE2="$(echo "$ALL_DIFF" | sed -n '2p')"
fi

if [ "$(echo "$ALL_DIFF" | wc -l)" -eq "0" ]; then

    echo "git repo is clean"

elif [ "$(echo "$ALL_DIFF" | wc -l)" -eq "2" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f1)" = "-INSERT INTO devices VALUES" ] && [ "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f1)" = "+INSERT INTO devices VALUES" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f1)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f1)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f2)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f2)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f1)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f1)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f4)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f4)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f5)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f5)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f6)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f6)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f7)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f7)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f8)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f8)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f9)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f9)" ] && [ "$(echo "$ALL_DIFF_LINE1" | cut -d'(' -f2 | cut -d',' -f10)" = "$(echo "$ALL_DIFF_LINE2" | cut -d'(' -f2 | cut -d',' -f10)" ]; then

    echo "git repo is clean(no new)"
    git add bitwarden.sql
    git commit -m "$COMMIT_MSG"

else
    git add bitwarden.sql
    git commit -m "$COMMIT_MSG"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_aws:$BITWARDEN_AWS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_oss:$BITWARDEN_OSS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_cos:$BITWARDEN_COS_S3_BUCKET/${keyPrefix}"

    rclone --config /usr/local/etc/rclone/rclone.conf --contimeout=3m --timeout=10m sync "${dirPath}" "bitwarden_b2:$BITWARDEN_B2_BUCKET/${keyPrefix}"
fi
