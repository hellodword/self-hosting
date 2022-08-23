
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


## s3 trigger

> TODO

- [阿里云](https://help.aliyun.com/document_detail/74765.html): 国内且支持 serverless 触发，且 serverless 有免费额度无低消
- [AWS](https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html): 缺点国外
- [腾讯云](https://intl.cloud.tencent.com/zh/document/product/583/9707): 仅支持 SCF 触发，有低消


---
[^inotify-channel-backup]: [^inotify-channel-backup](https://gist.github.com/alexbosworth/2c5e185aedbdac45a03655b709e255a3)