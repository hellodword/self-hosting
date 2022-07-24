#!/bin/bash

set -e

group="$1"
title="$2"
desp="$3"
sound="$4"


NOTIFY_URL="${NOTIFY_URL_1}"

day=$(date +"%d")
if [ $(($day%2)) == 0 ] ; then
  NOTIFY_URL="${NOTIFY_URL_2}"
fi

echo "$(date +'%Y-%m-%d %H:%M:%S') notify ${NOTIFY_URL}"

curl -s -X POST "${NOTIFY_URL}/${NOTIFY_TOKEN}/${title}/${desp}" --data "badge=1&isArchive=1&group=${group}&sound=${sound}"
