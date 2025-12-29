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

function pkg(){
    aapt dump badging $1 | grep "package: name"
}

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

## 配置命令补全
if [[ -n "$ZSH_VERSION" ]]; then

    # 1. 定义补全函数
    _apk_zsh_complete() {
        _files -g "*.apk"
    }

    _jad_zsh_complete() {
        _files -g "*.{apk,dex,jar}"
    }

    _jeb_zsh_complete() {
        _files -g "*.{apk,dex,jar,jdb2}"
    }

    _ida_zsh_complete() {
        # 匹配指定后缀 或 无后缀文件(排除带点文件)
        _files -g "*.{so,exe,i64}" -g "^*.*"
    }

    # 2. 注册补全 (仅当命令存在时)
    # command -v 会检查 函数、别名、PATH中的二进制文件
    # 忽略错误（兼容zinit in macos）
    if command -v pkg >/dev/null; then
        compdef _apk_zsh_complete pkg 2>/dev/null
    fi

    if command -v jad >/dev/null; then
        compdef _jad_zsh_complete jad 2>/dev/null
    fi

    if command -v jeb >/dev/null; then
        compdef _jeb_zsh_complete jeb 2>/dev/null
    fi

    if command -v ida >/dev/null; then
        compdef _ida_zsh_complete ida 2>/dev/null
    fi

# =============================================================================
# Bash 分支：仅使用 bash-completion (_filedir)
# =============================================================================
elif [[ -n "$BASH_VERSION" ]]; then

    # 检查 bash-completion 的核心函数 _filedir 是否存在
    if declare -f _filedir >/dev/null; then

        # 1. 定义补全函数
        _apk_bash_complete() {
            _filedir 'apk'
        }

        _jad_bash_complete() {
            _filedir '@(apk|dex|jar)'
        }

        _jeb_bash_complete() {
            _filedir '@(apk|dex|jar|jdb2)'
        }

        _ida_bash_complete() {
            _filedir '@(so|exe|i64)'
        }

        # 2. 注册补全 (同样仅当命令存在时注册，保持逻辑一致性)
        if command -v pkg >/dev/null; then complete -F _apk_bash_complete pkg; fi
        if command -v jad >/dev/null; then complete -F _jad_bash_complete jad; fi
        if command -v jeb >/dev/null; then complete -F _jeb_bash_complete jeb; fi
        if command -v ida >/dev/null; then complete -F _ida_bash_complete ida; fi

    else
        # =================================================
        # 补全未生效提示
        # =================================================
        RED='\033[0;31m'
        NC='\033[0m' # No Color
        
        echo -e "${RED}[Warning] Shell Completion Not Loaded:${NC}"
        echo "    Current shell is Bash, but 'bash-completion' package is not installed or sourced."
        echo "    Auto-completion for 'pkg', 'jad', and 'ida' will be disabled."
        echo "    To fix this, please install 'bash-completion' (e.g., apt install bash-completion)."
    fi
fi


pyhttp(){
    # 如果没有传入端口号，使用默认端口7788
    local port=${1:-7788}

    echo "启动 Python HTTP 服务器，监听端口 $port..."
    python3 -m http.server "$port"
}