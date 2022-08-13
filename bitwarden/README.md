## 部署

### AWS EC2

1. Install docker
    ```sh
    # 不考虑 watchtower，防止当小白鼠破坏文件
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh # --mirror Aliyun
    sudo docker pull vaultwarden/server:<version>

    # chown -R root:root /bitwarden

    sudo docker run --name bitwarden \
        --restart=always \
        -e WEB_VAULT_ENABLED=false \
        -e WEBSOCKET_ENABLED=false \
        -e ICON_SERVICE=internal \
        -e DISABLE_ICON_DOWNLOAD=true \
        -p 127.0.0.1:8080:80 -v /bitwarden:/data \
        -d \
        vaultwarden/server:<version>
    ```

2. EC2 会分配一个域名，用 [cloudflare workers 反代](./bitwarden-reverse-proxy.js)，实现多个域名支持，而且避免解析，防止未来 Cloudflare 出现解析泄露。


---
## 备份

### inotify

> [inotifywait backup](../inotify/README.md#inotifywait-backup)

### cron


---
## Tips

1. 理论上备份不需要加密[^bitwarden-zero-knowledge]

2. icon service

    1. [use icon redirect then instead of local cached](https://github.com/dani-garcia/vaultwarden/discussions/2338#discussioncomment-2256202)
    2. [icon service configuration](https://github.com/dani-garcia/vaultwarden/blob/b64cf27038f04368af8f25aa80782d37471e6303/.env.template#L145-L171)
    3. disable client icons: settings - option


---

[^bitwarden-zero-knowledge]: [The Bitwarden Blog: How End-to-End Encryption Paves the Way for Zero Knowledge](https://bitwarden.com/blog/end-to-end-encryption-and-zero-knowledge/)

