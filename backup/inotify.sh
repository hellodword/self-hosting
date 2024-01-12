#!/bin/bash
while true; do
    inotifywait -e moved_to,create,delete,modify -r /bitwarden
    # backup script
    bash /usr/local/etc/backup/bitwarden.sh inotify
done
