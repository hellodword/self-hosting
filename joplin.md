## 部署

> 对象存储勾选版本功能

---
## 使用

1. 初次打开，删除默认笔记、笔记本，设置加密，设置 S3 同步，同步成功
2. 在其他设备打开，删除默认笔记、笔记本，设置 S3 同步，取消勾选 `Fail-safe`，同步，输入密码，同步成功，勾选 `Fail-safe`


---
## TODO

- [x] 备份 cos 到 oss
    ```sh
    5  0,8-23 * * * (echo; rclone --config rclone.conf -vv sync joplin_cos:$JOPLIN_COS_S3_BUCKET joplin_oss:$JOPLIN_OSS_S3_BUCKET 2>&1) >> ~/.joplin.log && bash notify.sh "joplin-sync" "joplin-sync-to-oss" "ok" "silence" || bash notify.sh "joplin-sync" "joplin-sync-to-oss" "fail" "minuet"

    10 0,8-23 * * * (echo; rclone --config rclone.conf -vv sync joplin_cos:$JOPLIN_COS_S3_BUCKET joplin_aws:$JOPLIN_AWS_S3_BUCKET 2>&1) >> ~/.joplin.log && bash notify.sh "joplin-sync" "joplin-sync-to-aws" "ok" "silence" || bash notify.sh "joplin-sync" "joplin-sync-to-aws" "fail" "minuet"
    ```