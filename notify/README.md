
## bark

### heroku

> heroku free plan 每个月有时长限制
> heroku free plan 30 分钟无活动会 sleep，冷启动比较慢

1. 部署两个相同配置的 bark server 到 heroku 上
2. 按照单双日来决定使用哪个
3. 按照单双日来定期唤醒对应的域名
4. 无需添加域名到 bark app，可能影响休眠


```sh
0,15,30,45 * * * * bash bark-heroku-wakeup.sh
```


### 本地

> 一些场景下不需要服务器

```sh
sudo docker run --restart always --name bark -p 127.0.0.1:8080:8080 -e BARK_DEVICE_TOKEN= -e BARK_KEY= -d finab/bark-server bark-server -serverless
```

> 或者 curl 实现

---
## telegram

---
## wechat

---
## discord

