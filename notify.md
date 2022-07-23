## 已知

- bark 不支持端到端加密
- bark 很好用
- ~~server 酱支持端到端加密，但没有客户端支持，与微信强相关~~
- bark 支持一键部署在 heroku 上
- heroku free plan 每个月有时长限制
- heroku free plan 30 分钟无活动会 sleep，冷启动比较慢


## 对策

1. 部署两个相同配置的 bark server 到 heroku 上
2. 按照单双日来决定使用哪个
3. 按照单双日来定期唤醒对应的域名
4. 无需添加域名到 bark app，可能影响休眠


```sh
0,15,30,45 * * * * echo >> ~/.bark.log && env NOTIFY_URL_1= NOTIFY_URL_2= bash /path/to/notify-wakeup.sh >> ~/.bark.log 2>&1
```