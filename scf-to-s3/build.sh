#!/bin/bash

set -e

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -buildid=" -o ./s3uploader ./cmd/s3uploader

GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -buildid=" -o ./main .

zip main.zip main s3uploader

rm main