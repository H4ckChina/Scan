#!/bin/bash

# 定义一个标志来表示是否应该停止启动新的masscan进程
stop_masscan=false

# 定义一个函数来处理SIGINT信号
function handle_sigint {
    pkill -9 masscan
    rm -f paused.conf
    stop_masscan=true
}

# 设置捕获SIGINT信号
trap 'handle_sigint' SIGINT

# 改变发送SIGINT信号的快捷键
stty intr ^x

# 读取port.txt文件中的端口号
IFS=$'\n' read -d '' -r -a ports < port.txt

# 循环执行masscan
for ((i=0; i<${#ports[@]}; i++)); do
    # 检查是否应该停止启动新的masscan进程
    if $stop_masscan ; then
        echo "正在结束Masscan进程，并退出脚本..."
        exit 1
    fi
    port=${ports[i]}
    clear
    printf "+------------------------------------------------------+\n"
    printf "|    H4ck China Masscan    丨      Scan Port %-4s      |\n" "${ports[i]}"
    printf "+------------------------------------------------------+\n"
    printf "+------------------------------------------------------+\n"
    printf "|     Total Ports %-4d     丨     Residue Port %-4d    |\n" "${#ports[@]}" "$((${#ports[@]} - i))"
    printf "+------------------------------------------------------+\n"
    
    # 执行masscan扫描，并将结果输出到指定文件
    masscan -p$port -iL /root/Scan/ips.txt -oL /root/Scan/$port.txt --max-rate 20000
    # 等待masscan进程结束
    while true; do
        if pgrep masscan > /dev/null; then
            sleep 3
        else
            break
        fi
    done

    # 扫描完成后，过滤结果文件，只保留IP地址
    awk '{print $4}' /root/Scan/$port.txt | sed '/^$/d' | sort -u > /root/Scan/$port.tmp && mv /root/Scan/$port.tmp /root/Scan/$port.txt
done
    # masscan -p$port -iL /root/Scan/ips.txt -oL /root/Scan/$port.txt --wait 0 --max-retries 3 --max-rate 65000
