## 课后作业

### 建链练习
1. 获取建链脚本并赋权
```
$ curl -LO https://raw.githubusercontent.com/FISCO-BCOS/master/tools/build_chain.sh && chmod u+x build_chain.sh
```
2. 调用build_chain.sh创建4个节点
```
$ bash build_chain.sh -l "127.0.0.1:4" -p 30300,20200,8545
```
3. 唤起刚创建的4个节点
```
bash nodes/127.0.0.1/start_all.sh
```
4. 停止这4个节点
```
bash nodes/127.0.0.1/stop_all.sh
```

### 控制台练习
1. 启动控制台
![](./img/start.png)
2. 查看区块高度
![](./img/1getBlockNumber.png)
3. 获取区块数据
![](./img/2getBlockByNumber.png)
4. 部署HelloWorld智能合约
![](./img/3deploy.png)
5. 使用查看getDeployLog
![](./img/4getDeployLog.png)
6. 调用智能合约
![](./img/call.png)
7. 再次查看区块高度
![](./img/6getBlockNumber.png)
8. 再次查看区块数据
![](./img/7-1getBlockByNumber.png)
![](./img/7-2getBlockByNumber.png)
9. 按CNS方式部署HelloWorld智能合约
![](./img/8deployByCNS.png)
10. 再次查看区块高度
![](./img/9getBlockNumber.png)
11. 再次查看区块数据
![](./img/10-1getBlockByNumber.png)
![](./img/10-2getBlockByNumber.png)
![](./img/10-3getBlockByNumber.png)
![](./img/10-4getBlockByNumber.png)