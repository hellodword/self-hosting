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

    sudo apt install resolvconf nginx jq iptables-persistent rclone sqlite3 inotify-tools
    ```

2. ~~EC2 会分配一个域名，用 [cloudflare workers 反代](./bitwarden-reverse-proxy.js)，实现多个域名支持，而且避免解析，防止未来 Cloudflare 出现解析泄露。~~ 现在 IPv6 only，没有 IPv4 那样的 public DNS。


---
## 备份

### inotify

> [inotifywait backup](../backup/README.md#inotifywait-backup)

### ~~cron~~

### restore

```sh
# download bitwarden.sql
sqlite3 db.sqlite3 < bitwarden.sql

docker run --rm --name bitwarden \
        -e WEB_VAULT_ENABLED=false \
        -e WEBSOCKET_ENABLED=false \
        -e ICON_SERVICE=internal \
        -e DISABLE_ICON_DOWNLOAD=true \
        -p 127.0.0.1:8080:80 -v `pwd`:/data \
        vaultwarden/server:<version>

docker run --rm --network=host -it ubuntu bash
# apt update
# apt install curl unzip
# curl -L --output bw.zip https://github.com/bitwarden/clients/releases/download/cli-v2024.1.0/bw-linux-2024.1.0.zip
# unzip bw.zip
# ./bw config server http://127.0.0.1:8080
# ./bw login
# ./bw list items
```


---
## Tips

1. 理论上备份不需要加密[^bitwarden-zero-knowledge]

2. icon service

    1. [use icon redirect then instead of local cached](https://github.com/dani-garcia/vaultwarden/discussions/2338#discussioncomment-2256202)
    2. [icon service configuration](https://github.com/dani-garcia/vaultwarden/blob/b64cf27038f04368af8f25aa80782d37471e6303/.env.template#L145-L171)
    3. disable client icons: settings - option


---

[^bitwarden-zero-knowledge]: [The Bitwarden Blog: How End-to-End Encryption Paves the Way for Zero Knowledge](https://bitwarden.com/blog/end-to-end-encryption-and-zero-knowledge/)

