WHITE="\033[0m"
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"

adb_exe=adb
alias open_lsposed="adb shell am start -n com.android.shell/.BugreportWarningActivity -c org.lsposed.manager.LAUNCH_MANAGER"


get_all_adb_devices()
{
    all_adb_devices=()
    local device i=1
    for device in $(adb devices | egrep "\<device\>" | awk '{print $1}'); do
        all_adb_devices[$i]=$device
        i=$((++i))
    done
    return 0
}
select_adb_device()
{
    local count opt select_list
    get_all_adb_devices
    select_list=(${all_adb_devices[*]})
    count=${#select_list[@]}
    if [ ${count} -eq 0 ]; then
        echo "not found adb devices."
        return 1
    elif [ ${count} -ge 2 ]; then
        PS3="please select a num for adb device:"
        select opt in ${select_list[*]};do
            break;
        done
        echo $opt
        return 0
    else
        echo ${select_list}
        return 0
    fi
    echo
    return 1
}

## 提取设备中安装的所有apk文件到out目录中
# @param out 输出目录
aplapks(){
    selected_device=$(select_adb_device)
    if [ -z "$selected_device" ]; then
        echo "No selected device."
        exit 1
    fi
    output_dir="$1"
    if [ -z "$output_dir" ]; then
        echo "Usage: aplapks <output_directory>"
        exit 1
    fi
    mkdir -p  "$output_dir"
    $adb_exe -s "$selected_device" shell "pm list packages -f | sed -e 's/package://'" > "$output_dir/package_list.txt"
    while read -r package; do
        package_name=$(echo "$package" | rev | cut -d '=' -f 1 | rev)
        package_path=$(echo "$package" | rev | cut -d '=' -f 2- | rev)
        $adb_exe -s "$selected_device" pull $package_path $output_dir/${package_name}.apk
    done < "$output_dir/package_list.txt"
    echo "Done."
}

## 提取指定包名apk文件到当前目录下
# @param pkg 要提取的apk文件包名
aplapk() {
    selected_device=$(select_adb_device)
    if [ -z "$selected_device" ]; then
        echo "No selected device."
        return 1
    fi

    pkg_filter="$1"
    if [ -z "$pkg_filter" ]; then
        echo "Usage: aplapk <package_filter>"
        return 1
    fi

    # 获取匹配的包列表
    package_list=$($adb_exe -s "$selected_device" shell "pm list packages -f | sed -e 's/package://'" | grep "$pkg_filter")

    if [ -z "$package_list" ]; then
        echo "No packages found matching filter '$pkg_filter'."
        return 1
    fi

    # 处理每个匹配的包
    echo "$package_list" | while read -r package; do
        # 提取包名和路径
        package_name=$(echo "$package" | rev | cut -d '=' -f 1 | rev)
        package_path=$(echo "$package" | rev | cut -d '=' -f 2- | rev)

        # 拉取 APK 文件
        echo "Pulling APK: $package_name"
        $adb_exe -s "$selected_device" pull "$package_path" "./${package_name}.apk" || {
            echo "Failed to pull APK: $package_name"
        }
    done

    echo "Done."
}

apuid(){
    selected_device=$(select_adb_device)
    if [ -z "$selected_device" ]; then
        echo "No selected device."
        exit 1
    fi
    package_name="$1"
    if [ -z "$package_name" ]; then
        $adb_exe -s "$selected_device" shell "pm list packages -U"
    else
        $adb_exe -s "$selected_device" shell "pm list packages -U | grep $package_name"
    fi
}
apuids(){
    apuid
}