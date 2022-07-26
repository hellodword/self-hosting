# Self-hosting

## 服务对比

- 国内云服务商自建

    - 优点

        1. 支持预付费、充值，可以简化账单问题
        2. 腾讯云 Serverless 会分配域名，在某种程度上可以免备案使用国内的 Web 服务
        3. 墙

    - 缺点

        1. 政策风险，不小心可能被封禁
        2. 服务不稳定，容易调价或者直接砍掉

- 国外云服务商自建

    - 优点

        1. 隐私一般更优

    - 缺点

        1. 大陆用户注册使用往往违反 ToS，也有被封的风险
        2. 后付费，账单难以控制
        3. 墙

- 付费服务

    - 优点

        1. 用户体验一般最佳

    - 缺点

        1. 隐私风险
        2. 停止服务风险
        3. 数据可靠与安全性不足

## 实践

> 云服务商的 API 虽然功能更完整，但为了理清步骤，我选择记录控制台操作

1. [`bitwarden_rs`](./bitwarden)
2. [`joplin`](./joplin)
3. nextcloud