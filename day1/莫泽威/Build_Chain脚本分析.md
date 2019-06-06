Build_Chain.sh个人报告
---------------------

对输入的参数进行解析, 根据不同的参数来进行不同的运行.
----------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E8%A7%A3%E6%9E%90%E8%BE%93%E5%85%A5%E5%8F%82%E6%95%B0%E7%9A%84%E4%BB%A3%E7%A0%81.png)


检查脚本工作的环境，其中名字，目录与文件都必须要存在.
-------------

![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E6%A3%80%E6%9F%A5%E5%B7%A5%E4%BD%9C%E7%8E%AF%E5%A2%83%E7%9A%84%E5%AD%98%E5%9C%A8%E6%80%A7.png)

生成链与代理
-------------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E7%94%9F%E6%88%90%E9%93%BE%E4%B8%8E%E4%BB%A3%E7%90%86%E7%9A%84%E4%BB%A3%E7%A0%81.png)

在创建链的时候使用openssl创建密钥与请求，在请求中，先前生成的密钥是其钥匙，同时结果储存在ca.crt文件中.

创建节点
-----------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E5%88%9B%E5%BB%BA%E7%BB%93%E7%82%B9.png)

首先上面的部分是使用sha256加密算法创建请求，使用的是Agency的密钥。同时使用openssl创建时间长达10年的x509文件。
在生成节点的代码中，先生成独一无二的节点信息（path等），node id是 pubkey.

创建群组Group
---------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E5%88%9B%E5%BB%BA%E7%BE%A4%E7%BB%84.png)


生成节点的脚本
-----------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E7%94%9F%E6%88%90%E8%8A%82%E7%82%B9%E8%84%9A%E6%9C%AC.png)

![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E7%94%9F%E6%88%90%E8%8A%82%E7%82%B9%E8%84%9A%E6%9C%AC2.png)

生成服务端脚本
----------
![image](https://github.com/webanklabgroup5/webank/blob/master/day1/%E8%8E%AB%E6%B3%BD%E5%A8%81/image/%E7%94%9F%E6%88%90%E6%9C%8D%E5%8A%A1%E7%AB%AF%E8%84%9A%E6%9C%AC.png)


Main()运行步骤：
1. 先分析ip设置
2. 验证目录、环境等合理性
3. 从Github上下载源码(若所需文件不齐)
4. 生成 Cert.cnf 
5. 准备加密 CA 
6. 生成密钥（国密）
7. 生成配置




