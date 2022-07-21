## 部署

### [云开发 CloudBase Container Plugin](https://github.com/Tencent/cloudbase-framework/tree/8bb83bd9818b5fa1aeb18d13c8258a916f4ea802/packages/framework-plugin-container)

1. [云开发 CloudBase](https://console.cloud.tencent.com/tcb/env/index)
2. 新建 - 代码导入
3. [我的应用](https://console.cloud.tencent.com/tcb/apps/index) - 管理 - 环境变量 - 可以看到数据库相关的环境变量

### ~~TDSQL-C Serverless (MySQL)~~

1. [TDSQL-C - 集群列表](https://console.cloud.tencent.com/cynosdb/mysql) - 管理 - 自带备份管理
2. [TDSQL-C - 集群列表](https://console.cloud.tencent.com/cynosdb/mysql) - 登录 - 可以手动导出

### ~~云联网~~ [^tencent-cloud-lighthouse-tdsql-c]


1. [安全组](https://console.cloud.tencent.com/vpc/securitygroup) - 新建，开放 `TCP:3306` 给指定内网网段
2. 同账号同区云服务器可以直接连接，不同区或者轻量应用服务器会有网络隔离，需要云联网
3. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 新建 - 预付费 - 金 - 地域间限速 - 添加 TDSQL-C 对应的 VPC - 确定
    > [同地域（不区分同账号或跨账号）5Gbps 及以下带宽免费。同地域的服务等级均为金，且不可修改。](https://buy.cloud.tencent.com/price/ccn)
4. [轻量应用服务器 - 内网互联](https://console.cloud.tencent.com/lighthouse/ccn/index) - 对应区 - 关联云联网
5. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 管理 - 通过申请
6. [云联网](https://console.cloud.tencent.com/vpc/ccn) - 管理 - 路由表 - 启用轻量应用服务器对应路由


### 腾讯云对象存储

- ~~[创建自定义策略](https://console.cloud.tencent.com/cam/policy/createV2) - `空白模板` - `bitwarden-cos-writeonly`~~
    > resource 的文档是错的，uin 无效
    > uid 也就是 appid 在 [账号信息](https://console.cloud.tencent.com/developer) 中

    ```json
    {
        "version": "2.0",
        "statement": [
            {
                "effect": "allow",
                "action": [
                    "cos:ListParts",
                    "cos:PostObject",
                    "cos:PutObject*",
                    "cos:InitiateMultipartUpload",
                    "cos:UploadPart",
                    "cos:UploadPartCopy",
                    "cos:CompleteMultipartUpload",
                    "cos:AbortMultipartUpload",
                    "cos:ListMultipartUploads"
                ],
                "resource": "qcs::cos:ap-shanghai:uid/123456:name-of-cos/*"
            }
        ]
    }
    ```

1. [创建新用户](https://console.cloud.tencent.com/cam/user/create?systemType=FastCreateV2) - 不授权不关联
2. [对象存储 - 存储桶列表](https://console.cloud.tencent.com/cos/bucket) - `创建存储桶` - `私有` - 复制 `访问域名`
3. `权限管理` - `存储桶访问权限` - `添加用户` - `数据写入`
4. `基础配置` - `生命周期`
5. 可购买资源包


### 阿里云对象存储

1. [RAM 访问控制 - 创建权限策略](https://ram.console.aliyun.com/policies/new) - `对象存储` - `写操作` - `oss:PutObject` - 指定 Bucket - Object 为 *
2. [创建用户](https://ram.console.aliyun.com/users/new) - 复制 `AccessKey ID` `AccessKey Key`
3. [用户页面](https://ram.console.aliyun.com/users) - `添加权限` - 自定义策略
4. [对象存储 - Bucket 列表](https://oss.console.aliyun.com/bucket) - `创建 Bucket` - `私有` - 复制 `Endpoint（地域节点）` 和 `Bucket 域名`
5. `基础设置` - `生命周期`


### AWS S3

1. [Create bucket](https://s3.console.aws.amazon.com/s3/bucket/create?region=ap-southeast-1) 
2. [Create Policy](https://ap-southeast-1.console.aws.amazon.com/iam/home#/policies$new?step=edit) - `S3` - `PutObject` - `Specific ARN`
3. [IAM - Add User](https://ap-southeast-1.console.aws.amazon.com/iam/home#/users$new?step=details) - `Access key - Programmatic access` - `Use a permissions boundary to control the maximum user permissions`

### 云函数自动备份 CFS/TDSQL-C 到对象存储 [^scf-backup-database]

> 不完全信任 TDSQL-C 自带的备份/CFS 自带的快照，所以通过多家服务商的对象存储做额外的备份，备份不需要加密[^bitwarden-zero-knowledge]

1. [Serverless - 函数服务](https://console.cloud.tencent.com/scf/list) - 新建
2. `从头开始` - `事件函数` - `运行环境 Go 1` - `在线编辑` - 编译文件名为 main 然后压缩 zip 上传
3. `触发器配置` - `定时触发` - `每天` [^scf-cron]
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
7. `文件系统` - `启用` - `/mnt`
  > `（用户ID: 10000 | 用户组ID：10000 | 文件系统ID：cfs-a | 挂载点ID：cfs-b | 本地目录：/mnt/ | 远端目录：/）`
8. 测试和定时器触发环境有所不同，定时器触发时 `/tmp` 内的文件一定程度上可以复用

---
### 挂载 CFS 到轻量应用服务器

1. 云联网 - 轻量服务器内网互联 - 同意 - 路由表启用
2. 挂载
    ```sh
    sudo mkdir -p /bitwarden
    sudo mount -t nfs -o vers=4.0,noresvport 10.0.1.2:/ /bitwarden
    
    # 取消挂载
    sudo umount /bitwarden
    ```




---
## 手动修复

1. 本地运行 docker，生成导入数据，打包文件
2. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
3. 复制文件
    ```sh
    sudo mv mnt/* /bitwarden/
    sudo umount /bitwarden
    ```


---
## ~~轻量应用服务器运行~~

> API 网关 VPC 通道需要收费

1. [挂载 CFS 到轻量应用服务器](#挂载-cfs-到轻量应用服务器)
2. 轻量应用服务器防火墙 - 开放端口给内网 `10.0.0.0/8`
3. Install docker
    ```sh
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh --mirror Aliyun
    sudo docker pull vaultwarden/server:1.25.1

    sudo docker run --name bitwarden \
        --restart=always \
        -e WEB_VAULT_ENABLED=false \
        -e WEBSOCKET_ENABLED=false \
        -e ICON_SERVICE=internal \
        -e DISABLE_ICON_DOWNLOAD=true \
        -p 8000:80 -v /bitwarden:/data \
        -d \
        vaultwarden/server:1.25.1
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