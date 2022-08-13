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

echo "$(date +'%Y-%m-%d %H:%M:%S') ping ${NOTIFY_URL}"

curl -s "${NOTIFY_URL}/ping"
