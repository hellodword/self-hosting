## 部署

### [云开发 CloudBase Container Plugin](https://github.com/Tencent/cloudbase-framework/tree/8bb83bd9818b5fa1aeb18d13c8258a916f4ea802/packages/framework-plugin-container)

1. [云开发 CloudBase](https://console.cloud.tencent.com/tcb/env/index)
2. 新建 - 代码导入
3. [我的应用](https://console.cloud.tencent.com/tcb/apps/index) - 管理 - 环境变量 - 可以看到数据库相关的环境变量

### ~~TDSQL-C Serverless (MySQL)~~

1. [TDSQL-C - 集群列表](https://console.cloud.tencent.com/cynosdb/mysql) - 管理 - 自带备份管理
2. [TDSQL-C - 集群列表](https://console.cloud.tencent.com/cynosdb/mysql) - 登录 - 可以手动导出

### 云联网 [^tencent-cloud-lighthouse-tdsql-c]


1. [安全组](https://console.cloud.tencent.com/vpc/securitygroup) - 新建，开放 `TCP:3306` 给指定内网网段
2. 同账号同区云服务器可以直接连接，不同区或者轻量应用服务器会有网络隔离，需要云联网
3. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 新建 - 预付费 - 金 - 地域间限速 - 添加 TDSQL-C 对应的 VPC - 确定
    > [同地域（不区分同账号或跨账号）5Gbps 及以下带宽免费。同地域的服务等级均为金，且不可修改。](https://buy.cloud.tencent.com/price/ccn)
4. [轻量应用服务器 - 内网互联](https://console.cloud.tencent.com/lighthouse/ccn/index) - 对应区 - 关联云联网
5. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 管理 - 通过申请
6. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 管理 - 路由表 - 启用轻量应用服务器对应路由


---
### ~~云函数自动备份 CFS/TDSQL-C 到对象存储 [^scf-backup-database]~~

> 云函数计费改变，所以冻结了

> 不完全信任 TDSQL-C 自带的备份/CFS 自带的快照，所以通过多家服务商的对象存储做额外的备份，备份不需要加密[^bitwarden-zero-knowledge]

1. [Serverless - 函数服务](https://console.cloud.tencent.com/scf/list) - 新建
2. `从头开始` - `事件函数` - `运行环境 Go 1` - `在线编辑` - 编译文件名为 main 然后压缩 zip 上传
3. `触发器配置` - `定时触发` - `每天` [^scf-cron]
    ```
    // 东八区每天 0:40 和 12:40	
    0 40 0,12 * * * *
    ```
4. 创建后，编辑 - `内存` `64MB` - `执行超时时间` `60秒`
5. `异步调用` - `重试次数`
    ```json
    {
        "Message": "Error 9449: CynosDB serverless instance is resuming, please try connecting again",
        "Type": "MySQLError",
        "StackTrace": null,
        "ShouldExit": false
    }
    ```
6. `私有网络` - VPC 可以选择 Cloudbase 部署的 bitwarden 所在的 VPC
7. `文件系统` - `启用` - `/mnt/bitwarden`
  > `（用户ID: 10000 | 用户组ID：10000 | 文件系统ID：cfs-a | 挂载点ID：cfs-b | 本地目录：/mnt/bitwarden | 远端目录：/）`
8. 测试和定时器触发环境有所不同，定时器触发时 `/tmp` 内的文件一定程度上可以复用
9. 添加 API 网关触发器，配置超时 180，作为主动触发备份的途径

---
### 挂载 CFS 到轻量应用服务器

1. 云联网 - 轻量服务器内网互联 - 同意 - 路由表启用
2. 挂载
    ```sh
    sudo mkdir -p /mnt/bitwarden
    sudo mount -t nfs -o vers=4.0,noresvport 10.0.1.2:/ /mnt/bitwarden
    
    # 取消挂载
    sudo umount /mnt/bitwarden
    ```

---
### 保持 CFS 为挂载状态

> 未验证有效性

1. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
2. cron
    ```sh
    */5 * * * * ls /mnt/bitwarden/db.sqlite3 || mount -t nfs -o vers=4.0,noresvport 10.0.1.2:/ /mnt/bitwarden
    ```

---
### 定期备份

> inotify-tools 对 CFS 无效

```sh
40 1,8,10,12,14,16,18,20,22 * * * bash bitwarden-cfs.sh >> ~/.bitwarden.log 2>&1 && bash notify.sh "bitwarden-cfs-backup" "bitwarden-cfs-backup" "ok" "silence" || bash notify.sh "bitwarden-cfs-backup" "bitwarden-cfs-backup" "fail" "minuet"
```

---
### 保持 cloudbase 活跃

```sh
*/5 * * * * curl -s https://<name>.<region>.app.tcloudbase.com/
```

---
## 手动修复

1. 本地运行 docker，生成导入数据，打包文件
2. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
3. 复制文件
    ```sh
    sudo mv bitwarden/* /mnt/bitwarden/
    sudo umount /mnt/bitwarden
    ```

---
## 主动备份

> cloudbase 也有云函数，就算冻结了 scf，这里的云函数也依然可以运行，是否计费有待观察
> 所以可以在这里添加一个云函数，添加 HTTP 触发，云函数内通过云联网通知轻量云服务器，运行备份脚本


---
## ~~轻量应用服务器运行~~

> API 网关 VPC 通道需要收费

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
4. [新建云开发](https://console.cloud.tencent.com/tcb/env/index?action=CreateEnv) - `空白模版`



---
## TODO

- [ ] Cloudbase 冷启动时 CFS 挂载偶尔失败，导致无法读取数据库，计划利用 Cloudbase 做个应用中转请求到轻量云服务器（将 Cloudbase 当作低配 API 网关用）
- [ ] 应对更多风险
- [ ] 异常提醒
- [ ] bitwarder_rs -> wasm -> cloudflare workers

---
## Privacy

1. icon service

    1. [use icon redirect then instead of local cached](https://github.com/dani-garcia/vaultwarden/discussions/2338#discussioncomment-2256202)
    2. [icon service configuration](https://github.com/dani-garcia/vaultwarden/blob/b64cf27038f04368af8f25aa80782d37471e6303/.env.template#L145-L171)
    3. disable client icons: settings - option

---

[^tencent-cloud-lighthouse-tdsql-c]: [腾讯云Lighthouse轻量应用服务器接入TDSQL-C云原生数据库](https://blog.tsinbei.com/archives/157/)

[^scf-backup-database]: [使用 SCF 无服务器云函数定时备份数据库](https://cloud.tencent.com/developer/article/1158012)

[^bitwarden-zero-knowledge]: [The Bitwarden Blog: How End-to-End Encryption Paves the Way for Zero Knowledge](https://bitwarden.com/blog/end-to-end-encryption-and-zero-knowledge/)

[^scf-cron]: [SCF + 定时任务实现页面内容定时采集](https://cloud.tencent.com/document/product/583/50724)