## 部署

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
2. [对象存储 - 存储桶列表](https://console.cloud.tencent.com/cos/bucket) - `创建存储桶` - `文件版本` - `私有` - 复制 `访问域名`
3. `权限管理` - `存储桶访问权限` - `添加用户` - `数据读取、数据写入、权限读取`
4. `基础配置` - `生命周期`
5. 可购买资源包


### 阿里云对象存储

1. [RAM 访问控制 - 创建权限策略](https://ram.console.aliyun.com/policies/new) - `对象存储` - `写操作` - `oss:PutObject` - 指定 Bucket - Object 为 *
2. [创建用户](https://ram.console.aliyun.com/users/new) - 复制 `AccessKey ID` `AccessKey Key`
3. [用户页面](https://ram.console.aliyun.com/users) - `添加权限` - 自定义策略
4. [对象存储 - Bucket 列表](https://oss.console.aliyun.com/bucket) - `创建 Bucket` - `私有` - 复制 `Endpoint（地域节点）` 和 `Bucket 域名`
5. `基础设置` - `生命周期`



### 云函数自动备份 COS 到 OSS

> 不完全信任 COS 以及背后的腾讯账户体系，所以再利用 SCF 的 [COS 触发器](https://cloud.tencent.com/document/product/583/9707) 备份到阿里云 OSS

1. [Serverless - 函数服务](https://console.cloud.tencent.com/scf/list) - 新建
2. `从头开始` - `事件函数` - `运行环境 Go 1` - `在线编辑` - 编译文件名为 main 然后压缩 zip 上传
3. 创建后，编辑 - `内存` `64MB` - `执行超时时间` `60秒`
4. 

---
## 使用

1. 初次打开，删除默认笔记、笔记本，设置加密，设置 S3 同步，同步成功
2. 在其他设备打开，删除默认笔记、笔记本，设置 S3 同步，取消勾选 `Fail-safe`，同步，输入密码，同步成功，勾选 `Fail-safe`


---
## TODO

- [ ] scf 备份 cos 到 oss
