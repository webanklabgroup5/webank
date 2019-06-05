# build_chain.sh

## 主程序入口

### 1.check_env检查配置环境
- openssl
>
1.0.2<br>
1.1<br>
reSSL<br>

- 系统环境
>
macOS<br>
Linux<br>

### 2.parse_params $@ 处理输入选项

选项介绍（其他可选项详见官方文档）：

- l选项: 用于指定要生成的链的IP列表以及每个IP下的节点数，以逗号分隔。脚本根据输入的参数生成对应的节点配置文件，其中每个节点的端口号默认从30300开始递增，所有节点属于同一个机构和群组。
- f选项<br>
  - 用于根据配置文件生成节点，相比于l选项支持更多的定制。
  - 按行分割，每一行表示一个服务器，格式为IP:NUM AgencyName GroupList，每行内的项使用空格分割，不可有空行。
  - IP:NUM表示机器的IP地址以及该机器上的节点数。AgencyName表示机构名，用于指定使用的机构证书。GroupList表示该行生成的节点所属的组，以,分割。例如192.168.0.1:2 agency1 1,2表示ip为192.168.0.1的机器上有两个节点，这两个节点属于机构agency1，属于group1和group2。


### 3.main
- `ip_file`,`use_ip_param`,`ip_param`,`output_dir`<br>
	- `ip_file`：是由选项f声明的ip列表文件，详见上述
	- `use_ip_param`：使用f选项则为false，l选项为true
	- `ip_param`：使用l选项时声明的ip列表
	- `output_dir`：建链完毕输出文件目录
- 检查旧输出文件，存在则提示清除。
- 获取当前版本号
- 下载二进制包并检查
- 对每个ip，请求密钥并生成证书
	- 如果使用国密，则需检查tassl环境
  
#### 3.1 证书生成流程
1.生成链证书：gen\_chain\_cert()

- 联盟链委员会使用openssl命令请求私钥ca.key<br>
- 根据ca.key生成链证书ca.crt

``` bash
openssl genrsa -out $chaindir/ca.key 2048
# 生成一个2048位的RSA，保存为ca.key文件
openssl req -new -x509 -3650 -sub "/CN=$name/0=fisco-bcos/OU=chain" -key $chaindir/ca.key -out $chaindir/ca.crt
# -x509 输出一个X509格式的证书
# 利用CA的RSA密钥创建一个自签署的CA证书，保存为ca.crt
```

2.生成机构证书：gen\_agency\_cert()

- 机构使用openssl命令生成机构私钥agency.key
- 机构使用机构私钥agency.key得到机构证书请求文件agency.csr，发送agency.csr给联盟链委员会
- 联盟链委员会使用链私钥ca.key，根据得到机构证书请求文件agency.csr生成机构证书agency.crt，并将机构证书agency.crt发送给对应机构

``` bash
openssl genrsa -out $agencydir/agency.key 2048
openssl req -new -sha256 -subj "/CN=$name/O=fisco-bcos/OU=agency" -key $agencydir/agency.key -config $chain/cert.cnf -out $agencydir/agency.csr
openssl x509 -req -days 3650 -sha256 -CA $chain/ca.crt -CAkey $chain/ca.key -CAcreateserial\
  -in $agencydir/agency.csr -out $agencydir/agency.crt  -extensions v4_req -extfile $chain/cert.cnf
# 这里请求.csr文件和.crt证书使用了sha256加密算法
# 证书时长都是10年（过期了怎么办...）
```

3.生成节点/SDK证书 gen\_node\_cert()

- 节点生成私钥node.key和证书请求文件node.csr，机构管理员使用私钥agency.key和证书请求文件node.csr为节点/SDK颁发证书node.crt

``` bash
gen_cert_secp256k1 "$agpath" "$ndpath" "$node" node<br>
# nodeid is pubkey<br>
openssl ec -in $ndpath/node.key -text -noout | sed -n '7,11p' | tr -d ": \n" | awk '{print substr($0,3);}' | cat >$ndpath/node.nodeid<br>
# openssl x509 -serial -noout -in $ndpath/node.crt | awk -F= '{print $2}' | cat >$ndpath/node.serial
```

### 4.print_result
建链完毕输出信息


