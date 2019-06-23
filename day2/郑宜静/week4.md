# 郑宜静：第三周报告

## 使用 spring-boot-starter 部署课上的LAG积分合约

> 将区块链部署在服务器，Windows 环境下使用 IDE 进行开发

### 更改 application.yml 

```yml
encrypt-type: 0  # 0:standard, 1:guomi
group-channel-connections-config:
  all-channel-connections:
  - group-id: 1  #group ID
    connections-str:
                    - {服务器IP地址}:20200  # node listen_ip:channel_listen_port
#                    - 127.0.0.1:20201
 
channel-service:
  group-id: 1 # The specified group to which the SDK connects
  org-id: fisco # agency name
```

### 1. deploy函数测试

![deploy函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g46evqzf09j21gr08wwfd.jpg)

### 2. transfer函数测试

![transfer函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g46evqyexfj210207dwf2.jpg)

### 3. load函数测试

![load函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g46evqxt1pj21c70bxjsl.jpg)

## 进一步理解区块链概念
