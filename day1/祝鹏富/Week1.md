# <center>微众银行区块链实训</center>
### <center>第一周周报</center>

## 本周工作内容
#### 1. 认识了解 FISCO BCOS 平台
- FISCO BCOS 是一个稳定、高效、安全的区块链底层平台，经过了外部多家机构、多个应用，长时间在生产环境运行的实际检验。
#### 2. 学习 FISCO BCOS 平台的基本使用
- 下载安装脚本build_chain.sh
```
$ curl -LO https://raw.githubusercontent.com/FISCO-BCOS/master/tools/build_chain.sh && chmod u+x build_chain.sh
```
- 配置及安装
```
$ ./build_chain.sh -l "127.0.0.1:4" -p 30300,20200,8545
```
- 启动链
```
$ cd nodes/127.0.0.1
$ ./start_all.sh
```
- 检查进程及端口监听
```
$ ps -ef | grep -v grep | grep fisco-bcos
$ netstat -ntlp | grep fisco-bcos
```
- 检查日志输出
```
$ tail -f node*/log/log* | grep connected
$ tail -f node*/log/log* | grep +++
```
- 控制台使用
```
# 下载控制台
$ bash <(curl -s https://raw.githubusercontent.com/FISCO-BCOS/console/master/tools/download_console.sh)
# 启动控制台
$ ./console/start.sh
# 查看控制台使用命令
[group:1]> help
```
- 编写/调用合约
此处不过多叙述，详情参考 [Day1](https://github.com/webanklabgroup5/Day1/blob/master/%E7%A5%9D%E9%B9%8F%E5%AF%8C/day1.md) 报告或 [FISCO BCOS](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/manual/console.html) 技术文档
#### 3. 下周计划
- 继续深入阅读 FISCO BCOS 技术文档
- 根据文档尝试控制台各种操作