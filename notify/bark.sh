#!/bin/bash

set -e

SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
cd $SCRIPT_DIR

. .env

if [ -z "${DEVICE_TOKEN}" ]; then
    echo "DEVICE_TOKEN"
    exit 1
fi

APNS_HOST_NAME=api.push.apple.com
AUTH_KEY_ID=LH4T9V5U4R
TEAM_ID=5U8LBRXG3A
TOPIC=me.fin.bark
TOKEN_KEY_FILE=/tmp/AuthKey_LH4T9V5U4R_5U8LBRXG3A.p8

cat > ${TOKEN_KEY_FILE} << EOF
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg4vtC3g5L5HgKGJ2+
T1eA0tOivREvEAY2g+juRXJkYL2gCgYIKoZIzj0DAQehRANCAASmOs3JkSyoGEWZ
sUGxFs/4pw1rIlSV2IC19M8u3G5kq36upOwyFWj9Gi3Ejc9d3sC7+SHRqXrEAJow
8/7tRpV+
-----END PRIVATE KEY-----
EOF

# https://developer.apple.com/documentation/usernotifications/sending_push_notifications_using_command-line_tools
JWT_ISSUE_TIME=$(date +%s)
JWT_HEADER=$(printf '{ "alg": "ES256", "kid": "%s" }' "${AUTH_KEY_ID}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_CLAIMS=$(printf '{ "iss": "%s", "iat": %d }' "${TEAM_ID}" "${JWT_ISSUE_TIME}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
JWT_HEADER_CLAIMS="${JWT_HEADER}.${JWT_CLAIMS}"
JWT_SIGNED_HEADER_CLAIMS=$(printf "${JWT_HEADER_CLAIMS}" | openssl dgst -binary -sha256 -sign "${TOKEN_KEY_FILE}" | openssl base64 -e -A | tr -- '+/' '-_' | tr -d =)
AUTHENTICATION_TOKEN="${JWT_HEADER}.${JWT_CLAIMS}.${JWT_SIGNED_HEADER_CLAIMS}"

group="$1"
title="$2"
desp="$3"
sound="$4"

# desp=$(echo "$desp" | sed ':a;N;$!ba;s/\r//g')
# desp=$(echo "$desp" | sed ':a;N;$!ba;s/\n/\\n/g')
# desp=$(echo "$desp" | sed 's/\"/\\"/g')

desp="${desp:${#desp}<4000?0:-4000}"
desp=$(echo "$desp" | jq -Rsa .)

if [ -z "${sound}" ]; then
    sound="1107"
else
    sound="${sound}.caf"
fi

# https://github.com/Finb/bark-server/blob/3aa064e5d98eaaed7e1f28f79510586109347e1e/apns/apns.go#L98
curl -s --header "apns-topic: $TOPIC" \
     --header "apns-push-type: alert" \
     --header "authorization: bearer $AUTHENTICATION_TOKEN" \
     --http2 "https://${APNS_HOST_NAME}/3/device/${DEVICE_TOKEN}" \
     --data '{"aps":{"alert":{"body":'"${desp}"',"title":"'"${title}"'"},"category":"myNotificationCategory","mutable-content":1,"sound":"'"${sound}"'","thread-id":"'"${group}"'"},"badge":"1","group":"'"${group}"'","isarchive":"1"}'
