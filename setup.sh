#!/bin/bash

# set -x

work_dir=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}" )" && pwd)
config_profile=$work_dir/profile/re.profile
comments="  # shelltools setup."

_config_vim()
{
    cat $work_dir/config/.vimrc >> $HOME/.vimrc
}

_config_pip()
{
    if [ ! -d "$HOME/.pip" ]; then
        echo "Directory $HOME/.pip does not exist. Creating..."
        mkdir -p "$HOME/.pip"
    fi
    cat $work_dir/config/pip.conf > $HOME/.pip/pip.conf
}

_config_git()
{
    local git_username="$1"
    local git_email="$2"

    if [ -z "$git_username" ] || [ -z "$git_email" ]; then
        echo "Usage: _config_git <git_username> <git_email>"
        return 1
    fi

    git config --global init.defaultBranch main

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --abbrev-commit --all --date=relative"

    git config --global user.name $git_username
    git config --global user.email $git_email
}



_config_settings()
{
    echo "==> config Android sdk."
    read -p "Input NDK version(example 21.4.7075529):  " ndk_version
    [ -n "$ndk_version" ] && configutil_write_config ANDROID_SDK_NDK_VERSION "$ndk_version"
    
    read -p "Input sdk build-tools version(example 30.0.3):  " buildtools_version
    [ -n "$buildtools_version" ] && configutil_write_config ANDROID_SDK_BUILD_TOOLS_VERSION "$buildtools_version"
    echo "==> config Android sdk."

    read -p "Input IDA home dir(example /Applications/IDA Professional 9.2.app):  " ida_home
    [ -n "$ida_home" ] && configutil_write_config IDA_HOME "$ida_home"
    read -p "Input JEB home dir(example \$HOME/Amysoftware/JEB):  " jeb_home
    [ -n "$jeb_home" ] && configutil_write_config JEB_HOME "$jeb_home"
    read -p "Input Jadx home dir(example \$HOME/Amysoftware/jadx):  " jadx_home
    [ -n "$jadx_home" ] && configutil_write_config JADX_HOME "$jadx_home"

    read -p "Do you want to configure git、pip、something(y/n):  " conf_flag
    if [ "$conf_flag" = "y" ]; then
        read -p "Do you want to configure git(y/n):  " git_conf_flag
        if [ "$git_conf_flag" = "y" ]; then
            read -p "Input git username:  " git_username
            read -p "Input git email:  " git_email
            _config_git git_username git_email
            echo "The Git configuration is complete."
        else
            echo "No need to configure Git."
        fi

        read -p "Do you want to configure pip(y/n):  " pip_conf_flag
        if [ "$pip_conf_flag" = "y" ]; then
            _config_pip
            pip config list
            echo "The pip configuration is complete."
        else
            echo "No need to configure pip."
        fi

        read -p "Do you want to configure vim(y/n):  " vim_conf_flag
        if [ "$vim_conf_flag" = "y" ]; then
            _config_vim
            echo "The vim configuration is complete."
        else
            echo "No need to configure vim."
        fi

    else
        echo "No need to configure."
    fi

}

_clear_old_profile()
{
    if [ `uname` = "Darwin" ];then
    sed -i '' -e "/${comments}/d" "$1"
    else
        sed -i "/${comments}/d" "$1"
    fi
}

_add_new_profile()
{
    if [ "x$(cat "$1" | grep -w "$comments")" = "x" ];then
        echo "source $config_profile $comments" >> "$1"
    fi
}

wprofile=~/.bash_profile

if [ ! -f "$wprofile" ]; then
    touch "$wprofile"

    current_shell=$(basename "$SHELL")

    case "$current_shell" in
        bash)
            target_rc=~/.bashrc
            ;;
        zsh)
            target_rc=~/.zshrc
            ;;
        *)
            echo "Unsupported shell: $current_shell"
            exit 1
            ;;
    esac

    # 将 source 命令添加到目标配置文件
    printf "\nif [ -f $wprofile ]; then\n    source $wprofile\nfi\n" >> "$target_rc"
    echo "Added 'source $wprofile' to $target_rc"
else
    echo "$wprofile already exists."
fi

_clear_old_profile $wprofile
_add_new_profile $wprofile


source "${work_dir}/config/configutil"
_config_settings

source $wprofile
