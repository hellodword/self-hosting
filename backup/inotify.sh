#!/bin/bash

set -x

while true; do
    inotifywait -e moved_to,create,delete,modify -r /bitwarden
    # backup script
    /usr/local/etc/backup/bitwarden.sh inotify
done
