#!/bin/bash

set -e

rm main.zip || echo

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -buildid=" -o ./s3uploader ./cmd/s3uploader

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -buildid=" -o ./main ./cmd/scf

zip -j main.zip main s3uploader bitwarden-cfs.sh ../notify/notify.sh

rm main
rm s3uploader