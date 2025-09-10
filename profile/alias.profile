alias ll="ls -alF"
alias lg="ll | grep"


if [ `uname` = "Darwin" ];then
    # 删除网上下载标志
    alias delnet="sudo xattr -r -d com.apple.quarantine ."
    # 配置tar来排除Mac的隐藏文件
    alias tarc="tar --disable-copyfile --exclude='.DS_Store' -zcvf"
    # 立刻睡眠屏幕
    alias sleep_screen="pmset displaysleepnow"
    # ifconfig获得en0网卡ip
    alias ip="ifconfig | grep -A 7 \"^en0\""
elif [ `uname` = "Linux" ];then
    # ifconfig获得eth0网卡ip
    alias ip="ifconfig | grep -A 7 \"^eth0\""
    alias pc="proxychains"
    if grep -iq "ubuntu" /etc/os-release; then
        alias openit='nautilus . &'
    fi
else
    echo "Unknown OS"
fi

# 获得本机ip
alias py_getip="python -c \"import socket;print([(s.connect(('8.8.8.8', 53)), s.getsockname()[0], s.close()) for s in [socket.socket(socket.AF_INET, socket.SOCK_DGRAM)]][0][1])\""
# 获得当前时间
alias py_time="python -c \"import datetime; print(datetime.datetime.now().strftime('%Y/%m/%d %H:%M:%S'))\""

