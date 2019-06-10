# 第一周周报

## FISCO-BCOS

* 搭建FISCO-BCOS区块链
	* 准备环境openssl，curl
	* 下载安装脚本build_chain.sh
	* 配置及安装
		* 注意build_chain.sh 选项及参数含义
		* [build_chain分析](./build_chain分析.md)
	* 启动链
	* 检查进程及端口监听
		* netstat命令及选项
	* 检查日志输出
* 学习使用FISCO-BCOS控制台
	* 准备环境jdk
	* 下载控制台
	* 配置控制台
		* 将节点sdk目录下的`ca.crt`、`node.crt`和`node.key`文件拷贝到`conf`目录下。
		* 否则将导致无法连接到节点，无法启动控制台
	* 启动控制台
	* 检查是否成功启动
	* 使用控制台<br>
		* [控制台](./day1控制台.md)



