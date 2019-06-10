## 脚本理解

### 生成证书

#### gen_chain_cert()
```
gen_chain_cert() {
    path="$2"
    name=$(getname "$path")
    echo "$path --- $name"
    dir_must_not_exists "$path"
    check_name chain "$name"
    
    chaindir=$path
    mkdir -p $chaindir
    openssl genrsa -out $chaindir/ca.key 2048
    openssl req -new -x509 -days 3650 -subj "/CN=$name/O=fisco-bcos/OU=chain" -key $chaindir/ca.key -out $chaindir/ca.crt
    mv cert.cnf $chaindir
}
```
- 输出长度为248的私钥，并保存在ca.key文件中
- 根据ca.key文件生成ca.crt
- genrsa，rsa表示非对称加密算法。
- 使用`-new`表示生成一个新的证书请求。

#### gen_node_cert()
```
gen_node_cert() {
    if [ "" == "$(openssl ecparam -list_curves 2>&1 | grep secp256k1)" ]; then
        echo "openssl don't support secp256k1, please upgrade openssl!"
        exit $EXIT_CODE
    fi

    agpath="$2"
    agency=$(getname "$agpath")
    ndpath="$3"
    node=$(getname "$ndpath")
    dir_must_exists "$agpath"
    file_must_exists "$agpath/agency.key"
    check_name agency "$agency"
    dir_must_not_exists "$ndpath"	
    check_name node "$node"

    mkdir -p $ndpath

    gen_cert_secp256k1 "$agpath" "$ndpath" "$node" node
    #nodeid is pubkey
    openssl ec -in $ndpath/node.key -text -noout | sed -n '7,11p' | tr -d ": \n" | awk '{print substr($0,3);}' | cat >$ndpath/node.nodeid
    # openssl x509 -serial -noout -in $ndpath/node.crt | awk -F= '{print $2}' | cat >$ndpath/node.serial
    cp $agpath/ca.crt $agpath/agency.crt $ndpath

    cd $ndpath

    echo "build $node node cert successful!"
}
```
- 生成节点私钥node.key和证书请求文件node.crt
- `openssl ec`为椭圆曲线密钥处理工具。

### 生成脚本

#### generate_script_template()
```
generate_script_template()
{
    local filepath=$1
    cat << EOF > "${filepath}"
#!/bin/bash
SHELL_FOLDER=\$(cd \$(dirname \$0);pwd)
EOF
    chmod +x ${filepath}
}
```
- 生成脚本的模板函数
- 并赋予脚本可执行的权限。

#### generate_node_scripts()
```
generate_node_scripts()
{
    local output=$1
    local docker_tag="latest"
    generate_script_template "$output/start.sh"
    local ps_cmd="\`ps aux|grep \${fisco_bcos}|grep -v grep|awk '{print \$2}'\`"
    local start_cmd="nohup \${fisco_bcos} -c config.ini 2>>nohup.out"
    local stop_cmd="kill \${node_pid}"
    local pid="pid"
    local log_cmd="cat nohup.out"
    if [ ! -z ${docker_mode} ];then
        ps_cmd="\`docker ps |grep \${SHELL_FOLDER//\//} | grep -v grep|awk '{print \$1}'\`"
        start_cmd="docker run -d --rm --name \${SHELL_FOLDER//\//} -v \${SHELL_FOLDER}:/data --network=host -w=/data fiscoorg/fiscobcos:${docker_tag} -c config.ini >>nohup.out"
        stop_cmd="docker kill \${node_pid} 2>/dev/null"
        pid="container id"
        log_cmd="docker logs \${SHELL_FOLDER//\//}"
    fi
    cat << EOF >> "$output/start.sh"
fisco_bcos=\${SHELL_FOLDER}/../${bcos_bin_name}
cd \${SHELL_FOLDER}
node=\$(basename \${SHELL_FOLDER})
node_pid=${ps_cmd}
if [ ! -z \${node_pid} ];then
    echo " \${node} is running, ${pid} is \$node_pid."
    exit 0
else 
    ${start_cmd} &
    sleep 1.5
fi
try_times=4
i=0
while [ \$i -lt \${try_times} ]
do
    node_pid=${ps_cmd}
    if [ ! -z \${node_pid} ];then
        echo -e "\033[32m \${node} start successfully\033[0m"
        exit 0
    fi
    sleep 0.5
    ((i=i+1))
done
echo -e "\033[31m  Exceed waiting time. Please try again to start \${node} \033[0m"
${log_cmd}
exit 1
EOF
    generate_script_template "$output/stop.sh"
    cat << EOF >> "$output/stop.sh"
fisco_bcos=\${SHELL_FOLDER}/../${bcos_bin_name}
node=\$(basename \${SHELL_FOLDER})
node_pid=${ps_cmd}
try_times=5
i=0
while [ \$i -lt \${try_times} ]
do
    if [ -z \${node_pid} ];then
        echo " \${node} isn't running."
        exit 0
    fi
    [ ! -z \${node_pid} ] && ${stop_cmd} > /dev/null
    sleep 0.6
    node_pid=${ps_cmd}
    if [ -z \${node_pid} ];then
        echo -e "\033[32m stop \${node} success.\033[0m"
        exit 0
    fi
    ((i=i+1))
done
echo "  Exceed maximum number of retries. Please try again to stop \${node}"
exit 1
EOF
}
```

- 生成暂停和启动节点的脚本，start.sh和stop.sh

#### generate_server_scripts()
```
generate_server_scripts()
{
    local output=$1
    genTransTest "${output}"
    generate_script_template "$output/start_all.sh"
    # echo "ip_array=(\$(ifconfig | grep inet | grep -v inet6 | awk '{print \$2}'))"  >> "$output/start_all.sh"
    # echo "if echo \${ip_array[@]} | grep -w \"${ip}\" &>/dev/null; then echo \"start node_${ip}_${i}\" && bash \${SHELL_FOLDER}/node_${ip}_${i}/start.sh; fi" >> "${output_dir}/start_all.sh"
    cat << EOF >> "$output/start_all.sh"
for directory in \`ls \${SHELL_FOLDER}\`  
do  
    if [[ -d "\${SHELL_FOLDER}/\${directory}" && -f "\${SHELL_FOLDER}/\${directory}/start.sh" ]];then  
        echo "try to start \${directory}"
        bash \${SHELL_FOLDER}/\${directory}/start.sh &
    fi  
done  
sleep 3.5
EOF
    generate_script_template "$output/stop_all.sh"
    cat << EOF >> "$output/stop_all.sh"
for directory in \`ls \${SHELL_FOLDER}\`  
do  
    if [[ -d "\${SHELL_FOLDER}/\${directory}" && -f "\${SHELL_FOLDER}/\${directory}/stop.sh" ]];then  
        echo "try to stop \${directory}"
        bash \${SHELL_FOLDER}/\${directory}/stop.sh &
    fi  
done  
sleep 3
EOF
}
```

- 生成启动所有节点和停止所有节点的脚本。

### 主函数

#### main()
- 首先判断`use_ip_param`的值，判断是否填了ip
- `dir_must_not_exists ${output_dir}`判断是否已经生成过脚本了。
- 然后判断是否指定版本，若无则获取最新的脚本。
- 在非docker模式下，判断os和路径是否指定。
- 判断是否指定证书，没有则新建。
- 生成CA证书，生成国密证书，给所有ip生成私钥。
- 给每个ip和结点生成对应的启动、停止脚本。
- 最后删除旧的日志文件。