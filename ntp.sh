#!/usr/bin/env bash

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

banner(){
    clear
echo "\
############################################################

   Debian 一键 NTP 时间同步脚本
         Powered by ChatGPT

############################################################
"
}

install_chrony(){
    echo -e "${Info} 更新软件源并安装 chrony ..."
    apt update -y && apt install -y chrony

    if [[ $? -ne 0 ]]; then
        echo -e "${Error} chrony 安装失败！"
        exit 1
    fi
}

write_config(){
    echo -e "${Info} 写入 /etc/chrony/chrony.conf ..."

cat > /etc/chrony/chrony.conf <<EOF
# ======== NTP 同步服务器 ========
pool ntp.aliyun.com iburst
pool time.google.com iburst
pool ntp.ubuntu.com iburst
pool pool.ntp.org iburst

# ======== Drift 文件 ========
driftfile /var/lib/chrony/drift

# ======== RTC 同步 ========
rtcsync

# ======== 日志 ========
logdir /var/log/chrony
EOF
}

start_chrony(){
    echo -e "${Info} 启动 chrony 服务 ..."
    systemctl restart chrony
    systemctl enable chrony
}

force_sync(){
    echo -e "${Info} 正在强制同步时间 ..."
    chronyc makestep
}

show_status(){
    echo -e "${Info} 当前同步状态："
    chronyc tracking
    echo "----------------------------------------"
    chronyc sources -v
}

main(){
    banner
    install_chrony
    write_config
    start_chrony
    force_sync
    show_status
    echo -e "${Green_font_prefix}=== 时间同步完成！===${Font_color_suffix}"
}

main
