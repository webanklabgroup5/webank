# 郑宜静：第四周报告

## 使用 spring-boot-starter 部署课上的LAG积分合约

> 将区块链部署在服务器，Windows 环境下使用 IDE 进行开发
> [项目代码地址](https://github.com/TheProudSoul/LAGC_SDK)

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

### 1. 编译合约

![编译合约](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dk97u1akj20n90iywip.jpg)

### 1. deploy函数测试

![deploy函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dka0e86oj20v40axq6q.jpg)

### 2. load函数测试

![load函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dkampy9jj20uo07uq5h.jpg)

### 3. transfer函数测试

![transfer函数测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dkb98cxqj20vc0ehaeu.jpg)

### 4. 获取账户地址测试

![获取账户地址测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dkbrbekfj20rd0ffq6i.jpg)

### 5. 获取账户余额测试

![获取账户余额测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dkcjyko9j20pi0b5q5w.jpg)

### 6. 获取总发行积分测试

![获取总发行积分测试](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dkd0oqxmj20rb0fnjvo.jpg)

### 其他账号调用合约

1. 修改application.yml中的user-key改为原先被转账用户
2. 重新进行账户transfer测试对原来的账户转账100积分
3. 查看原来账户积分余额：100000-1000+100=99100

![转账100积分](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dke3scvzj20su022mxq.jpg)

![查看原来账户积分余额](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4dked9t39j20bs02zjru.jpg)

## 进一步理解区块链概念

> 1. 区块链的存储基于分布式数据库；
> 2. 数据库是区块链的数据载体，区块链是交易的业务逻辑载体；
> 3. 区块链按时间序列化区块数据，整个网络有一个最终确定状态；
> 4. 区块链只对添加有效，对其他操作无效；
> 5. 交易基于非对称加密的公私钥验证；
> 6. 区块链网络要求拜占庭将军容错；
> 7. 共识算法能够“解决”双花问题。

### 以太坊的核心概念

1. 智能合约虚拟机 EVM 和 Solidity 编程语言
2. 账户模型：以太坊上的账户有两种类型，第一类叫做合约账户 CA（Contracts Accounts)，第二类叫做外部账户 EOA（Externally Owned Accounts）
3. 以太币和 Gas：以太币可以看作是虚拟资产凭证；Gas 是执行智能合约操作的燃料（避免程序死循环消耗全网资源的情况出现）， 智能合约的每一个步骤都会消耗 Gas， Gas 是由以太坊的平台代币以太币转化而来，最小单位是 wei， 1ETH 相当于 10 的 18 次方 wei。
4. 交易和消息：以太坊上的交易是指 EOA 账户将一个**经过签名的数据包**发送到另外一个账户的过程，这个过程产生的账户状态变化将被存储到以太坊区块链上；消息指一个合约账户调用其他合约账户的过程。

### P2P网络

- 网络连接：以太坊 P2P 网络是一个完全加密的网络，提供 UDP 和
TCP 两种连接方式，主网默认 TCP 通信端口是 30303，推荐的 UDP 发现端口为 30301
- 拓扑结构：全分布式的拓扑结构

### 共识算法与分布式一致性算法

> 分布式系统面临了几个问题：一致性问题，可终止性问题、合法性问题。
>  
> - 可终止性可以理解为系统必须在有限的时间内给出一致性结果
> - 合法性是指提案必须是系统内的节点提出
> - 一致性是指在某个分布式系统中，任意节点的提案能够在约定的协议下被其他所有节点所认可

#### 有关分布式系统的定理

1. FLP 不可能性：即使网络通信完全可靠，只要产生了拜占庭错误，就不存在一个确定性的共识算法能够为异步分布式系统提供一致性。换句话来说就是，不存在一个通用的共识算法可以解决所有的拜占庭错误。
2. CAP 定理:在设计分布式系统的过程中， “一致性”“可用性”“分区容忍性”三者中，只能选择两个作为主要强化的点，另外一个必然会被弱化。

#### 区块链共识算法

1. PoW：通过计算能力来获得记账权，计算能力越强，获得记账权的概率越大
2. PoS：节点所拥有的币龄越多，获得的记账的概率就越大
3. DPoS（代理权益证明）：将 PoS 共识算法中的记账者转换为指定节点数组成的小圈子

### PoS

> 解决使用 PoW 挖矿出现大量资源浪费的问题
> CoinAge（币龄）：币数量乘以天数

产生的问题：

1. 币发行的问题
2. 由于币龄是与时间挂钩的，这也意味着用户可以无限囤积一定的币，等过了很久再一次性挖矿发起攻击
3. 用户倾向于囤积代币,币流通的不充分
4. 离线攻击
5. Nothing at Stake（无成本利益）：在 PoS 系统上挖矿几乎没有成本，这也就意味着分叉非常方便

### 哈希与加密算法

#### 哈希算法

> 4个特性：
> 
> 1. 原像不可逆
> 2. 难题友好性
> 3. 发散性
> 4. 抗碰撞性

把任意的交易数据做成数据摘要，然后再一个一个链接起来，形成数据块的链式结构

通过验证每个区块间接地验证交易，然后每个交易原数据也可以做成哈希数据摘要，用于验证交易数据的完整性

![](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4bjkef82tj21230l00yq.jpg)

这种链式结构具备发散传导性，越往历史以前的篡改，越容易导致大面积的影响，这也叫做历史逆向修改困难

#### 非对称加密算法

![](http://ww1.sinaimg.cn/large/7b19d4ddgy1g4bjpv1c24j207o0mudh7.jpg)

## 未完全捋顺

区块链中的PKI系统
