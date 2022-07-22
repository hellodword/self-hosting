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
    rclone --config /path/to/rclone.conf -vv sync cos:joplin oss:joplin

    rclone --config /path/to/rclone.conf -vv sync cos:joplin aws:joplin
    ```

    ```sh
    0  1,8,12,16,20,22 * * * rclone --config /path/to/rclone.conf -vv sync cos:joplin oss:joplin >> ~/.joplin.log 2>&1

    20 1,8,12,16,20,22 * * * rclone --config /path/to/rclone.conf -vv sync cos:joplin aws:joplin >> ~/.joplin.log 2>&1
    ```