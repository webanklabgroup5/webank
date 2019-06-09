# build_chain 脚本阅读报告

## check_env

- 检查 openssl 安装情况和有关系统环境变量设置
- 查看操作系统以及设置OS变量

## parse_params

- 根据命令行选项和参数设置变量

## main

### output_dir

设置输出文件夹，如果没有该文件夹，创建文件夹
定义 IP 地址

### get fisco_version

设置 fisco_version 变量

### download fisco-bcos and check it

判断应下载的 fisco-bcos 版本，解压，权限设置

- 是否 docker 模式
- 操作系统类型
- 是否国密模式

### prepare CA

1. 在输出目录下生成相关数字证书文件
2. 如果是国密模式则继续生成国密数字证书文件
3. 针对每一个 IP 地址：

> - 检查 IP 地址是否符合正则表达式
> - 生成节点证书
> - 生成配置文件

## print_result

打印脚本执行结果
