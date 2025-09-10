# 更便捷的nohup，也会保存日志到临时目录（或当前目录）
mynohup() {
    # 获取系统的临时目录，如果TMPDIR不可用则使用当前目录
    local temp_dir=${TMPDIR:-./}
    
    # 使用当前时间戳生成日志文件名
    local current_timestamp=$(date +%Y-%m-%d_%H-%M-%S)
    local nohup_log="${temp_dir}nohup_$current_timestamp.log"
    
    # 运行nohup命令，并将输出重定向到指定的日志文件
    nohup "$@" > "$nohup_log" 2>&1 &
    
    # 输出日志文件的位置
    echo "Output redirected to $nohup_log"
}


## 获取Apk文件的包名
### param1: Apk文件路径
_apk_complete() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=($(compgen -W "$(ls *.apk)" -- "$cur"))
}

function pkg(){
    aapt dump badging $1 | grep "package: name"
}
complete -F _apk_complete pkg


## 配置jadx
if [ -n "$JADX_HOME" ]; then
    alias jadx="$JADX_HOME/bin/jadx"
    __JADX_EXE="$JADX_HOME/bin/jadx-gui"
    function jad() {
        if [ -z "$1" ]; then
            # 如果没有参数，直接执行jadx
            nohup $__JADX_EXE >/dev/null 2>&1 &
        else
            nohup $__JADX_EXE "$1" >/dev/null 2>&1 &
        fi
    }
    complete -F _apk_complete jad
fi

## 配置jeb
if [ -n "$JEB_HOME" ]; then
    if [ `uname` = "Darwin" ];then
        __JEB_EXE="$JEB_HOME/jeb_macos.sh"
        function jeb() {
            if [ -z "$1" ]; then
                # 如果没有参数，直接执行JEB
                nohup $__JEB_EXE >/dev/null 2>&1 &
            else
                nohup $__JEB_EXE "$1" >/dev/null 2>&1 &
            fi
        }
    fi
fi

## 配置IDA
if [ -n "$IDA_HOME" ]; then
    if [ "$(uname)" = "Darwin" ];then
        __IDA_EXE="$IDA_HOME/Contents/MacOS/ida"
    else
        __IDA_EXE="$IDA_HOME/ida"
    fi
    function ida() {
        if [ -z "$1" ]; then
            # 如果没有参数，直接执行IDA
            nohup $__IDA_EXE >/dev/null 2>&1 &
        else
            nohup $__IDA_EXE "$1" >/dev/null 2>&1 &
        fi
    }
fi

pyhttp(){
    # 如果没有传入端口号，使用默认端口7788
    local port=${1:-7788}

    echo "启动 Python HTTP 服务器，监听端口 $port..."
    python3 -m http.server "$port"
}