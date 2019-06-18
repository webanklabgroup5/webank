# LAG 积分智能合约部署

[LAG积分智能合约](/LAGCredit.sol)

## 运行 get_account.sh 
```bash
chmod u+x get_account.sh
./get_account.sh
[INFO] Account Address   : 0x4ce84af2f9eef4225cf80e4ed2bab42be7e128e8
[INFO] Private Key (pem) : accounts/0x4ce84af2f9eef4225cf80e4ed2bab42be7e128e8.pem
[INFO] Private Key: 0x43f1dbbf14428a0a045aa6a055fbb0cf7ceee824b5d0b3560fe817cddcefc71a
```
* 账号，公钥，用于双方完成交易
* 私钥.pem文件所在位置
* 私钥，密码，用于登陆控制台

## 实验流程
| 商家 | 用户 |
| :------ | :------ |
|使用私钥登陆|使用私钥登陆|
|部署合约(初始积分1000)||
|查询余额(1000)|查询余额(0)|
|向用户转账(客户消费时获得积分)(666)||
|查询余额(334)|查询余额(666)|
||向商家转账(客户消费时使用积分)(250)|
|查询余额(584)|查询余额(416)|

## 实验结果
### 商家
![1](/images/merchant.png)

### 客户
![2](/images/customer.png)

## 实验心得
* 登陆控制台使用私钥(相当于密码)
* 交易双方只知道对方的公钥(相当于账号)，根据对方的公钥完成交易

# Spring Boot Starter

```bash
$ git clone https://github.com/FISCO-BCOS/spring-boot-starter.git
cd ~/fisco/nodes/127.0.0.1/sdk 
cp ca.crt node.crt node.key ~/spring-boot-starter/src/test/resources/
cd ~/spring-boot-starter/
chmod u+x gradlew
./gradlew build
```
![3](/images/build.png)