
## inotifywait backup

> inotify-tools 对 CFS 这类远程挂载无效

- directory
    ```sh
    #!/bin/bash
    while true; do
        inotifywait -e moved_to,create,delete,modify -r /bitwarden/
        # backup script
        output="$(bash /path/to/bitwarden-tar.sh inotify 2>&1)" || exit_code=$?
        if [ "$exit_code" != "" ]; then
            echo "tar  $output"
            # notify
        fi
    done
    ```

- files
    ```sh
    #!/bin/bash
    while true; do
        inotifywait -e moved_to,create,delete,modify /bitwarden/db.sqlite3 /bitwarden/db.sqlite3-wal
        # backup script
    done
    ```


---
[^inotify-channel-backup]: [^inotify-channel-backup](https://gist.github.com/alexbosworth/2c5e185aedbdac45a03655b709e255a3)