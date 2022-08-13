#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

NOTIFY_URL="${NOTIFY_URL_1}"
day=$(date +"%d")
if [ $(($day%2)) == 0 ] ; then
  NOTIFY_URL="${NOTIFY_URL_2}"
fi

group="$1"
title="$2"
desp="$3"
sound="$4"

echo "$(date +'%Y-%m-%d %H:%M:%S') notify ${NOTIFY_URL} ${group} ${title} ${desp}"

curl -s -X POST "${NOTIFY_URL}/${NOTIFY_TOKEN}/${title}/${desp}" --data "badge=1&isArchive=1&group=${group}&sound=${sound}"
