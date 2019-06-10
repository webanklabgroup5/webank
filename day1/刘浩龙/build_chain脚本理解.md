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
```
main()
{
output_dir="$(pwd)/${output_dir}"
[ -z $use_ip_param ] && help 'ERROR: Please set -l or -f option.'
if [ "${use_ip_param}" == "true" ];then
    ip_array=(${ip_param//,/ })
elif [ "${use_ip_param}" == "false" ];then
    if ! parse_ip_config $ip_file ;then 
        echo "Parse $ip_file error!"
        exit 1
    fi
else 
    help 
fi


dir_must_not_exists ${output_dir}
mkdir -p "${output_dir}"

# get fisco_version
if [ -z "${fisco_version}" ];then
    fisco_version=$(curl -s https://raw.githubusercontent.com/FISCO-BCOS/FISCO-BCOS/master/release_note.txt | sed "s/^[vV]//")
fi

# download fisco-bcos and check it
if [ -z ${docker_mode} ];then
    if [[ -z ${bin_path} && -z ${OS} ]];then
        bin_path=${output_dir}/${bcos_bin_name}
        package_name="fisco-bcos.tar.gz"
        [ ! -z "$guomi_mode" ] && package_name="fisco-bcos-gm.tar.gz"
        Download_Link="https://github.com/FISCO-BCOS/FISCO-BCOS/releases/download/v${fisco_version}/${package_name}"
        LOG_INFO "Downloading fisco-bcos binary from ${Download_Link} ..." 
        curl -LO ${Download_Link}
        tar -zxf ${package_name} && mv fisco-bcos ${bin_path} && rm ${package_name}
        chmod a+x ${bin_path}
    elif [[ -z ${bin_path} && ! -z ${OS} ]];then
        echo "Please use docker mode to run fisco-bcos on macOS Or compile source code and use -e option to specific fisco-bcos binary path"
        exit 1
    else
        echo "Checking fisco-bcos binary..."
        bin_version=$(${bin_path} -v)
        if [ -z "$(echo ${bin_version} | grep 'FISCO-BCOS')" ];then
            LOG_WARN "${bin_path} is wrong. Please correct it and try again."
            exit 1
        fi
        if [[ ! -z ${guomi_mode} && -z $(echo ${bin_version} | grep 'gm') ]];then
            LOG_WARN "${bin_path} isn't gm version. Please correct it and try again."
            exit 1
        fi
        if [[ -z ${guomi_mode} && ! -z $(echo ${bin_version} | grep 'gm') ]];then
            LOG_WARN "${bin_path} isn't standard version. Please correct it and try again."
            exit 1
        fi
        echo "Binary check passed."
    fi
fi
if [ -z ${CertConfig} ] || [ ! -e ${CertConfig} ];then
    # CertConfig="${output_dir}/cert.cnf"
    generate_cert_conf "cert.cnf"
else 
   cp ${CertConfig} .
fi

if [ "${use_ip_param}" == "true" ];then
    for i in $(seq 0 ${#ip_array[*]});do
        agency_array[i]="agency"
        group_array[i]=1
    done
fi

# prepare CA
echo "=============================================================="
if [ ! -e "$ca_file" ]; then
    echo "Generating CA key..."
    dir_must_not_exists ${output_dir}/chain
    gen_chain_cert "" ${output_dir}/chain >${output_dir}/${logfile} 2>&1 || fail_message "openssl error!"
    mv ${output_dir}/chain ${output_dir}/cert
    if [ "${use_ip_param}" == "false" ];then
        for agency_name in ${agency_array[*]};do
            if [ ! -d ${output_dir}/cert/${agency_name} ];then 
                gen_agency_cert "" ${output_dir}/cert ${output_dir}/cert/${agency_name} >${output_dir}/${logfile} 2>&1
            fi
        done
    else
        gen_agency_cert "" ${output_dir}/cert ${output_dir}/cert/agency >${output_dir}/${logfile} 2>&1
    fi
    ca_file="${output_dir}/cert/ca.key"
fi

if [ -n "$guomi_mode" ]; then
    check_and_install_tassl

    generate_cert_conf_gm "gmcert.cnf"

    echo "Generating Guomi CA key..."
    dir_must_not_exists ${output_dir}/gmchain
    gen_chain_cert_gm "" ${output_dir}/gmchain >${output_dir}/build.log 2>&1 || fail_message "openssl error!"  #生成secp256k1算法的CA密钥
    mv ${output_dir}/gmchain ${output_dir}/gmcert
    gen_agency_cert_gm "" ${output_dir}/gmcert ${output_dir}/gmcert/agency >${output_dir}/build.log 2>&1
    ca_file="${output_dir}/gmcert/ca.key"    
fi


echo "=============================================================="
echo "Generating keys ..."
nodeid_list=""
ip_list=""
count=0
server_count=0
groups=
ip_node_counts=
groups_count=
for line in ${ip_array[*]};do
    ip=${line%:*}
    num=${line#*:}
    checkIP=$(echo $ip|grep -E "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")
    if [ -z "${checkIP}" ];then
        LOG_WARN "Please check IP address: ${ip}"
    fi
    [ "$num" == "$ip" ] || [ -z "${num}" ] && num=${node_num}
    echo "Processing IP:${ip} Total:${num} Agency:${agency_array[${server_count}]} Groups:${group_array[server_count]}"
    [ -z "${ip_node_counts[${ip//./}]}" ] && ip_node_counts[${ip//./}]=0
    for ((i=0;i<num;++i));do
        echo "Processing IP:${ip} ID:${i} node's key" >> ${output_dir}/${logfile}
        node_dir="${output_dir}/${ip}/node${ip_node_counts[${ip//./}]}"
        [ -d "${node_dir}" ] && echo "${node_dir} exist! Please delete!" && exit 1
        
        while :
        do
            gen_node_cert "" ${output_dir}/cert/${agency_array[${server_count}]} ${node_dir} >${output_dir}/${logfile} 2>&1
            mkdir -p ${conf_path}/
            rm node.param node.private node.pubkey agency.crt
            mv *.* ${conf_path}/

            #private key should not start with 00
            cd ${output_dir}
            privateKey=$(openssl ec -in "${node_dir}/${conf_path}/node.key" -text 2> /dev/null| sed -n '3,5p' | sed 's/://g'| tr "\n" " "|sed 's/ //g')
            len=${#privateKey}
            head2=${privateKey:0:2}
            if [ "64" != "${len}" ] || [ "00" == "$head2" ];then
                rm -rf ${node_dir}
                continue;
            fi

            if [ -n "$guomi_mode" ]; then
                gen_node_cert_gm "" ${output_dir}/gmcert/agency ${node_dir} >${output_dir}/build.log 2>&1
                mkdir -p ${gm_conf_path}/
                mv ./*.* ${gm_conf_path}/

                #private key should not start with 00
                cd ${output_dir}
                privateKey=$($TASSL_CMD ec -in "${node_dir}/${gm_conf_path}/gmnode.key" -text 2> /dev/null| sed -n '3,5p' | sed 's/://g'| tr "\n" " "|sed 's/ //g')
                len=${#privateKey}
                head2=${privateKey:0:2}
                if [ "64" != "${len}" ] || [ "00" == "$head2" ];then
                    rm -rf ${node_dir}
                    continue;
                fi
            fi
            break;
        done
        cat ${output_dir}/cert/${agency_array[${server_count}]}/agency.crt >> ${node_dir}/${conf_path}/node.crt

        if [ -n "$guomi_mode" ]; then
            cat ${output_dir}/gmcert/agency/gmagency.crt >> ${node_dir}/${gm_conf_path}/gmnode.crt
            cat ${output_dir}/gmcert/gmca.crt >> ${node_dir}/${gm_conf_path}/gmnode.crt

            #move origin conf to gm conf
            rm ${node_dir}/${conf_path}/node.nodeid
            cp ${node_dir}/${conf_path} ${node_dir}/${gm_conf_path}/origin_cert -r
        fi

        if [ -n "$guomi_mode" ]; then
            nodeid=$($TASSL_CMD ec -in "${node_dir}/${gm_conf_path}/gmnode.key" -text 2> /dev/null | perl -ne '$. > 6 and $. < 12 and ~s/[\n:\s]//g and print' | perl -ne 'print substr($_, 2)."\n"')
        else
            nodeid=$(openssl ec -in "${node_dir}/${conf_path}/node.key" -text 2> /dev/null | perl -ne '$. > 6 and $. < 12 and ~s/[\n:\s]//g and print' | perl -ne 'print substr($_, 2)."\n"')
        fi

        if [ -n "$guomi_mode" ]; then
            #remove original cert files
            rm ${node_dir:?}/${conf_path} -rf
            mv ${node_dir}/${gm_conf_path} ${node_dir}/${conf_path}
        fi


        if [ "${use_ip_param}" == "false" ];then
            node_groups=(${group_array[server_count]//,/ })
            for j in ${node_groups[@]};do
                if [ -z "${groups_count[${j}]}" ];then groups_count[${j}]=0;fi
                echo "groups_count[${j}]=${groups_count[${j}]}"  >> ${output_dir}/${logfile}
        groups[${j}]=$"${groups[${j}]}node.${groups_count[${j}]}=${nodeid}
    "
                ((++groups_count[j]))
            done
        else
        nodeid_list=$"${nodeid_list}node.${count}=${nodeid}
    "
        fi
        
        ip_list=$"${ip_list}node.${count}="${ip}:$(( ${ip_node_counts[${ip//./}]} + port_start[0] ))"
    "
        ip_node_counts[${ip//./}]=$(( ${ip_node_counts[${ip//./}]} + 1 ))
        ((++count))
    done
    sdk_path="${output_dir}/${ip}/sdk"
    if [ ! -d ${sdk_path} ];then
        gen_node_cert "" ${output_dir}/cert/${agency_array[${server_count}]} "${sdk_path}">${output_dir}/${logfile} 2>&1
        cat ${output_dir}/cert/${agency_array[${server_count}]}/agency.crt >> node.crt
        rm node.param node.private node.pubkey node.nodeid agency.crt
        cp ${output_dir}/cert/ca.crt ${sdk_path}/
        cd ${output_dir}
    fi
    ((++server_count))
done 

ip_node_counts=()
echo "=============================================================="
echo "Generating configurations..."
cd ${current_dir}
server_count=0
for line in ${ip_array[*]};do
    ip=${line%:*}
    num=${line#*:}
    [ "$num" == "$ip" ] || [ -z "${num}" ] && num=${node_num}
    [ -z "${ip_node_counts[${ip//./}]}" ] && ip_node_counts[${ip//./}]=0
    echo "Processing IP:${ip} Total:${num} Agency:${agency_array[${server_count}]} Groups:${group_array[server_count]}"
    for ((i=0;i<num;++i));do
        echo "Processing IP:${ip} ID:${i} config files..." >> ${output_dir}/${logfile}
        node_dir="${output_dir}/${ip}/node${ip_node_counts[${ip//./}]}"
        generate_config_ini "${node_dir}/config.ini" ${ip} "${group_array[server_count]}"
        if [ "${use_ip_param}" == "false" ];then
            node_groups=(${group_array[${server_count}]//,/ })
            for j in ${node_groups[@]};do
                generate_group_genesis "$node_dir/${conf_path}/group.${j}.genesis" "${j}" "${groups[${j}]}"
                generate_group_ini "$node_dir/${conf_path}/group.${j}.ini"
            done
        else
            generate_group_genesis "$node_dir/${conf_path}/group.1.genesis" "1" "${nodeid_list}"
            generate_group_ini "$node_dir/${conf_path}/group.1.ini"
        fi
        generate_node_scripts "${node_dir}"
        ip_node_counts[${ip//./}]=$(( ${ip_node_counts[${ip//./}]} + 1 ))
    done
    generate_server_scripts "${output_dir}/${ip}"
    if [ -z ${docker_mode} ];then cp "$bin_path" "${output_dir}/${ip}/fisco-bcos"; fi
    if [ -n "$make_tar" ];then cd ${output_dir} && tar zcf "${ip}.tar.gz" "${ip}" && cd ${current_dir};fi
    ((++server_count))
done 
rm ${output_dir}/${logfile}
if [ "${use_ip_param}" == "false" ];then
echo "=============================================================="
    for l in $(seq 0 ${#groups_count[@]});do
        if [ ! -z "${groups_count[${l}]}" ];then echo "Group:${l} has ${groups_count[${l}]} nodes";fi
    done
fi

}

```

- 首先判断`use_ip_param`的值，判断是否填了ip
- `dir_must_not_exists ${output_dir}`判断是否已经生成过脚本了。
- 然后判断是否指定版本，若无则获取最新的脚本。
- 在非docker模式下，判断os和路径是否指定。
- 判断是否指定证书，没有则新建。
- 生成CA证书，生成国密证书，给所有ip生成私钥。
- 给每个ip和结点生成对应的启动、停止脚本。
- 最后删除旧的日志文件。