#! /bin/bash

set -e

sudo docker run --rm --name bitwarden \
    -e WEB_VAULT_ENABLED=false \
    -e WEBSOCKET_ENABLED=false \
    -e ICON_SERVICE=internal \
    -e DISABLE_ICON_DOWNLOAD=true \
    -p 8888:80 -v $(pwd)/tests/mnt:/data \
    vaultwarden/server:1.25.1
