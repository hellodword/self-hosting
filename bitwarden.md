## 部署

### ~~服务器运行~~

> API 网关 VPC 通道需要收费所以弃用

1. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
2. 轻量应用服务器防火墙 - 开放端口给内网 `10.0.0.0/8`
3. Install docker
    ```sh
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --mirror Aliyun
    sudo docker pull vaultwarden/server:latest

    sudo docker run --name bitwarden \
        --restart=always \
        -e WEB_VAULT_ENABLED=false \
        -e WEBSOCKET_ENABLED=false \
        -e ICON_SERVICE=internal \
        -e DISABLE_ICON_DOWNLOAD=true \
        -p 8000:80 -v /mnt/bitwarden:/data \
        -d \
        vaultwarden/server:latest
    ```


### CloudBase 运行

> [免费额度](https://cloud.tencent.com/document/product/876/47816)

1. [部署容器](./clouds.md#云开发-cloudbase-container-pluginhttpsgithubcomtencentcloudbase-frameworktree8bb83bd9818b5fa1aeb18d13c8258a916f4ea802packagesframework-plugin-container-部署容器)
2. [保活](./clouds.md#保持-cloudbase-活跃)

---
## 备份

### 主动备份

1. [挂载 CFS](./clouds.md#挂载-cfs-到轻量应用服务器)
2. cron 执行脚本

### 被动备份

> cloudbase 也有云函数，就算冻结了 scf，这里的云函数也依然可以运行，是否计费有待观察
> 所以可以在这里添加一个云函数，添加 HTTP 触发，云函数内通过云联网通知轻量云服务器，运行备份脚本

1. [云联网连接 cloudbase 和轻量应用服务器](./clouds.md#云联网)
2. 

---
## 回滚

### 还原文件

1. 停止运行云端应用
2. 本地运行 docker，生成导入数据，打包文件
3. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
4. 复制文件
    ```sh
    sudo mv bitwarden/* /mnt/bitwarden/
    sudo umount /mnt/bitwarden
    ```
5. 重启云端应用


---
## Tips

1. 理论上备份不需要加密[^bitwarden-zero-knowledge]

2. icon service

    1. [use icon redirect then instead of local cached](https://github.com/dani-garcia/vaultwarden/discussions/2338#discussioncomment-2256202)
    2. [icon service configuration](https://github.com/dani-garcia/vaultwarden/blob/b64cf27038f04368af8f25aa80782d37471e6303/.env.template#L145-L171)
    3. disable client icons: settings - option



---
## TODO

- [ ] Cloudbase 计费改变，迁移到 AWS + 域名
- [ ] 备份改成每日打包一次关键文件的 tarball + 每日多次 rclone sync 所有文件


---

[^bitwarden-zero-knowledge]: [The Bitwarden Blog: How End-to-End Encryption Paves the Way for Zero Knowledge](https://bitwarden.com/blog/end-to-end-encryption-and-zero-knowledge/)

