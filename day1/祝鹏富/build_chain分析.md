## build_chain.sh脚本分析

### 脚本功能简介
build_chain.sh脚本用于快速生成一条链中节点的配置文件，脚本依赖于openssl。

### 基本使用
- 使用`-l`选项指定节点IP和数目，或使用`-f`选项使用一个指定格式的配置文件。`-l`和`-f`必须且只能使用其中一个。
- 测试时用可`-T`或`-i`选项。`-T`选项开启log级别到DEBUG，`-i`选项设置RPC和channel监听`0.0.0.0`，p2p模块默认监听`0.0.0.0`。

### build_chain.sh分析

- `help()`方法，在终端输入`./build_chain.sh -help`可以查看各命令选项信息。
```
Usage:
    -l <IP list>                        [Required] "ip1:nodeNum1,ip2:nodeNum2" e.g:"192.168.0.1:2,192.168.0.2:3"
    -f <IP list file>                   [Optional] split by line, every line should be "ip:nodeNum agencyName groupList". eg "127.0.0.1:4 agency1 1,2"
    -e <FISCO-BCOS binary path>         Default download fisco-bcos from GitHub. If set -e, use the binary at the specified location
    -o <Output Dir>                     Default ./nodes/
    -p <Start Port>                     Default 30300,20200,8545 means p2p_port start from 30300, channel_port from 20200, jsonrpc_port from 8545
    -i <Host ip>                        Default 127.0.0.1. If set -i, listen 0.0.0.0
    -v <FISCO-BCOS binary version>      Default get version from FISCO-BCOS/blob/master/release_note.txt. eg. 2.0.0
    -d <docker mode>                    Default off. If set -d, build with docker
    -s <State type>                     Default storage. if set -s, use mpt 
    -S <Storage type>                   Default leveldb. if set -S, use external
    -c <Consensus Algorithm>            Default PBFT. If set -c, use Raft
    -C <Chain id>                       Default 1. Can set uint.
    -g <Generate guomi nodes>           Default no
    -z <Generate tar packet>            Default no
    -t <Cert config file>               Default auto generate
    -T <Enable debug log>               Default off. If set -T, enable debug log
    -F <Disable log auto flush>         Default on. If set -F, disable log auto flush
    -h Help
e.g
    ./tools/build_chain.sh -l "127.0.0.1:4"
```

- `LOG_WARN()`、`LOG_INFO()`，与日志相关，若在建链过程中产生了相关的日志信息，在终端输入`./build_chain.sh -log`会提示如下信息清除旧日志。
![](./img/-log.png)

- `parse_params()`方法，解析调用脚本时输入的命令选项。

- `print_result()`方法，输出调用脚本的结果。

- `check_env()`方法，检查`openssl`等环境是否搭建好

- `check_and_install_tassl()`方法，检查`tassl`环境是否搭建并判断是否需要下载。

