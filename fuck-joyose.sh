#!/data/data/com.termux/files/usr/bin/bash
# MIUI云控缓存清理工具
# @Updated 2025-10-25 03:45
# @Created 2025-10-23 13:53
# @Author Kei
# @Version 1.0.0-stable
# @Ref https://developer.android.google.cn/tools/adb?hl=zh-cn
# @Ref https://blog.csdn.net/weixin_40883833/article/details/133623434





# ================================基本功能及配置部分================================


# 配置项
PKG_ADSOLUTION="com.miui.systemAdSolution" # 智能服务（广告）
PKG_ANALYTICS="com.miui.analytics" # Analytics（遥测组件）
PKG_JOYOSE="com.xiaomi.joyose" # Joyose（云控组件）
IS_DEBUG_MODE="0" # 是否处于调试模式
PERMISSIONS=( # 权限集
    # 验证账户
    "android.permission.AUTHENTICATE_ACCOUNTS"
    # 查找设备上的账号
    "android.permission.GET_ACCOUNTS"
    "android.permission.GET_ACCOUNTS_PRIVILEGED"
    # 拥有完全的网络访问权限
    "android.permission.INTERNET"
    # 查看网络连接
    "android.permission.ACCESS_NETWORK_STATE"
    # 读取手机状态和身份
    "android.permission.READ_PHONE_STATE"
    "android.permission.READ_PRIVILEGED_PHONE_STATE"
    # 查看WLAN连接
    "android.permission.ACCESS_WIFI_STATE"
    # 检索正在运行的应用
    "android.permission.GET_TASKS"
    "android.permission.INSTALL_SELF_UPDATES"
    # 读取同步设置
    "android.permission.READ_SYNC_SETTINGS"
    # 防止手机休眠
    "android.permission.WAKE_LOCK"
    # 允许应用通过网络访问粗略的位置信息
    "android.permission.ACCESS_COARSE_LOCATION"
    # 允许应用通过GPS获取访问精确的位置信息
    "android.permission.ACCESS_FINE_LOCATION"
    # 在后台使用位置信息
    "android.permission.ACCESS_BACKGROUND_LOCATION"
    # 允许应用收集应用使用统计信息
    "android.permission.PACKAGE_USAGE_STATS"
    "android.permission.INTERACT_ACROSS_USERS"
    "android.permission.INTERACT_ACROSS_USERS_FULL"
    "com.xiaomi.permission.MICLOUD"
    "com.xiaomi.permission.CLOUD_MANAGER"
    "com.xiaomi.permission.ACCESS_SECURITY_DEVICE_CREDENTIAL"
    "com.xiaomi.xmsf.permission.USE_XMSF_UPLOAD"
    "miui.permission.USE_INTERNAL_GENERAL_API"
    "miui.cloud.finddevice.AccessFindDevice"
    # 与蓝牙设备配对
    "android.permission.BLUETOOTH"
    # 访问蓝牙设置
    "android.permission.BLUETOOTH_ADMIN"
    # 读写系统敏感设置
    "android.permission.WRITE_SECURE_SETTINGS"
    "android.permission.READ_SETTINGS"
    # 修改系统设置
    "android.permission.WRITE_SETTINGS"
    # 开机启动
    "android.permission.RECEIVE_BOOT_COMPLETED"
    # 更新设备状态
    "android.permission.UPDATE_DEVICE_STATS"
    "android.permission.MODIFY_NETWORK_ACCOUNTING"
    "miui.securitycenter.permission.ANALYTICS"
    # 连接WLAN网络和断开连接
    "android.permission.CHANGE_WIFI_STATE"
    "miui.packageinstaller.permission.ACTION_INFO"
    # 查询所有软件包
    "android.permission.QUERY_ALL_PACKAGES"
)
# 调试模式下，使用简化版权限集
[[ "$IS_DEBUG_MODE" == "1" ]] && PERMISSIONS=( # 权限集
    # 验证账户
    "android.permission.AUTHENTICATE_ACCOUNTS"
    # 拥有完全的网络访问权限
    "android.permission.INTERNET"
    # 查看网络连接
    "android.permission.ACCESS_NETWORK_STATE"
    # 查看WLAN连接
    "android.permission.ACCESS_WIFI_STATE"
    # 防止手机休眠
    "android.permission.WAKE_LOCK"
    # 连接WLAN网络和断开连接
    "android.permission.CHANGE_WIFI_STATE"
    "miui.packageinstaller.permission.ACTION_INFO"
)
# 日志配置
CURRENT_DATE=$(date +"%Y%m%d-%H%M%S") # 当前时间
LOG_TAG="fuck-joyose" # 日志文件名前缀
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/log" # 日志文件夹
LOG_FILE_CONSOLE="$LOG_DIR/${LOG_TAG}_${CURRENT_DATE}_con.log" # 控制台日志文件
LOG_FILE_ERROR="$LOG_DIR/${LOG_TAG}_${CURRENT_DATE}_err.log" # 错误日志文件
LOG_FILE_FULL="$LOG_DIR/${LOG_TAG}_${CURRENT_DATE}_full.log" # 完整日志文件
LOG_LEVEL="6" # 日志级别：3-err-错误 4-warning-警告 5-notice-重要 6-info-信息 7-debug-调试
IS_SIMPLIFIED_DISPLAY_MODE="1" # 是否启用精简打印模式
[[ "$IS_DEBUG_MODE" == "1" ]] && LOG_DIR="/storage/emulated/0/101o5_自用工具/fuck-joyose/log" # 调试模式下，重新定义日志文件夹
# 杂项配置，请勿修改





# ================================环境检测部分================================


# 普通环境：通过rish执行第一阶段，然后回到Termux执行第二阶段
# ADB环境：执行第一阶段
echo ""
echo "环境检测中..."
ps -p "$$"
if ls "/storage/emulated/0/Android/data/" >/dev/null 2>&1 && ! $(pkg show termux-am >/dev/null 2>&1); then
    echo "【访问ADB环境，进入第一阶段——正式执行】"
    echo ""
elif $(pkg show termux-am >/dev/null 2>&1); then
    # 调试模式下，进入第零阶段前清屏
    [[ "$IS_DEBUG_MODE" == "1" ]] && clear && echo "调试模式，自动清理屏幕..."
    echo "【访问普通环境，进入第零阶段——调用rish】"
    # 调用rish，在ADB环境中执行第一阶段
    until rish -c "sh '$(cd "$(dirname "$0")" && pwd)/$(basename "$0")' '$1'"; do
        echo "⚠️貌似无法连接到Shizuku，重试中..."
        # echo "⚠️请确保Shizuku服务及APP均处于运行状态。"
        sleep 1
    done
    # 调试模式下，进入下一阶段前暂停5秒
    # [[ "$IS_DEBUG_MODE" == "1" ]] && echo "5秒后将进入第二阶段..." && sleep 5
    echo ""
    echo "【回到普通环境，暂无第二阶段】"
    echo ""
    echo "【全部结束】"
    exit
else
    echo ""
    echo "当前环境不符合要求，无法执行当前脚本。请依次检查以下设置："
    echo "- 确保已经正确配置了 \`rish\`"
    echo "- 确保以上软件可以通过 PATH 环境变量直接访问"
    echo ""
    echo "当拥有 \`Android/data/\` 目录的访问权限且 \`pkg\` 不可用时（如ADB环境），本脚本会进入第一阶段——正式执行；"
    # echo "当软件 \`pkg\` 可用时，本脚本会进入第二阶段——执行合成脚本。"
    exit 1
fi





# ================================函数定义部分================================


# 基本日志写入函数部分====


# 为日志文件设置文件描述符
exec 4>>"$LOG_FILE_CONSOLE" 5>>"$LOG_FILE_ERROR" 6>>"$LOG_FILE_FULL"


# 写入控制台日志
function log_to_console_file() {
    echo "$*" 1>&4
}


# 写入错误日志
function log_to_error_file() {
    echo "$*" 1>&5
}


# 写入完整日志
function log_to_full_file() {
    echo "$*" 1>&6
}


# 各级别日志函数部分====


# 处理错误日志
function log_err() {
    [[ "$LOG_LEVEL" -ge "3" && "$IS_SIMPLIFIED_DISPLAY_MODE" -eq "0" ]] && { echo -e "\e[1;31m$*\e[0m"; log_to_console_file "$*"; }
    log_to_error_file "$*"
    log_to_full_file "$*"
}


# 处理警告日志
function log_warning() {
    [[ "$LOG_LEVEL" -ge "4" && "$IS_SIMPLIFIED_DISPLAY_MODE" -eq "0" ]] && { echo -e "\e[1;33m$*\e[0m"; log_to_console_file "$*"; }
    log_to_full_file "$*"
}


# 处理重要日志
function log_notice() {
    [[ "$LOG_LEVEL" -ge "5" ]] && { echo -e "\e[1;35m$*\e[0m"; log_to_console_file "$*"; }
    log_to_full_file "$*"
}


# 处理信息日志
function log_info() {
    # [[ "$LOG_LEVEL" -ge "6" ]] && { echo -e "\e[1;34m$*\e[0m"; log_to_console_file "$*"; }
    [[ "$LOG_LEVEL" -ge "6" ]] && { echo "$*"; log_to_console_file "$*"; }
    log_to_full_file "$*"
}


# 处理调试日志
function log_debug() {
    [[ "$LOG_LEVEL" -ge "7" ]] && { echo -e "\e[1;36m$*\e[0m"; log_to_console_file "$*"; }
    log_to_full_file "$*"
}


# 执行命令并记录日志
function do_cmd() {
    # 接收要执行的命令，及其描述
    local cmd="$1"
    local todo="$2"
    # 存储当前时间
    local time="$(date +'%Y-%m-%d %H:%M:%S.%N')"
    # 存储命令返回值，及其输出内容
    local code=""
    local res=""
    # 设置统一前缀
    local msg_prefix="#### "
    # 显示提示信息
    log_debug ""
    log_debug "${msg_prefix}time=$time"
    log_notice "${msg_prefix}todo=$todo"
    log_debug "${msg_prefix}cmd=$cmd"
    # 执行命令并保存结果
    res=$($cmd 2>&1)
    code="$?"
    log_debug "${msg_prefix}code=$code"
    # 根据命令返回值，确定进一步行为
    if [[ "$code" -eq "0" ]]; then
        log_info "${msg_prefix}res=$res"
        log_notice "✅"
    else
        log_to_error_file ""
        log_to_error_file "${msg_prefix}time=$time"
        log_to_error_file "${msg_prefix}todo=$todo"
        log_to_error_file "${msg_prefix}cmd=$cmd"
        log_to_error_file "${msg_prefix}code=$code"
        log_err "${msg_prefix}res=$res"
        log_notice "❌"
    fi
    return $code
}


function list_malware() {
    local user="$1"
    # local package="$2"
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    # [[ -z "$package" ]] && return 1
    echo "对用户 $user 列出已存在的流氓软件..."
    pm list packages --user "$user" | grep -Ei "^(.*)($PKG_ADSOLUTION|$PKG_ANALYTICS|$PKG_JOYOSE)$"
    return 0
}


# TODO: am 命令无法直接执行，只能在 adb shell 中执行。调用的 am 大概率是 termux-am，其命令与原生 am 不同
function stop() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 终止与 package 关联的所有进程。此命令仅终止可安全终止且不会影响用户体验的进程。
    # adb shell am kill --user "$user" "$package"
    # 强行停止与 package 关联的所有进程。
    # adb shell am force-stop --user "$user" "$package"
    do_cmd "am force-stop --user "$user" "$package"" "对用户 $user 软件包 $package 强行停止..." || state=1
    return $state
}


function revoke() {
    local user="$1"
    local package="$2"
    local permission="$3"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    [[ -z "$permission" ]] && return 1
    # 从应用撤消权限。
    # 在搭载 Android 6.0（API 级别 23）及更高版本的设备上，该权限可以是应用清单中声明的任何权限。
    # 在搭载 Android 5.1（API 级别 22）及更低版本的设备上，该权限必须是应用定义的可选权限。
    # adb shell pm revoke --user "$user" "$package" "$permission"
    do_cmd "pm revoke --user "$user" "$package" "$permission"" "对用户 $user 软件包 $package 撤销权限: $permission" || state=1
    return $state
}


function clear() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 删除与软件包关联的所有数据。
    # adb shell pm clear --user "$user" "$package"
    do_cmd "pm clear --user "$user" "$package"" "对用户 $user 软件包 $package 清除数据..." || state=1
    return $state
}


function disable() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 停用给定的软件包或组件（写为“package/class”）。
    # adb shell pm disable --user "$user" "$package"
    # adb shell pm disable-user --user "$user" "$package"
    do_cmd "pm disable --user "$user" "$package"" "对用户 $user 软件包 $package 停用..." || state=1
    return $state
}


function disable_u() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 停用给定的软件包或组件（写为“package/class”）。
    # adb shell pm disable --user "$user" "$package"
    # adb shell pm disable-user --user "$user" "$package"
    do_cmd "pm disable-user --user "$user" "$package"" "对用户 $user 软件包 $package 停用（用户级别）..." || state=1
    return $state
}


function uninstall_updates() {
    # local user="$1"
    local package="$1"
    local state=0
    # 如果未传入所需参数则返回错误代码
    # [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 卸载更新并还原至出厂版本。
    # adb shell pm uninstall-system-updates "$package"
    do_cmd "pm uninstall-system-updates "$package"" "对软件包 $package 卸载更新..." || state=1
    return $state
}


function uninstall() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    # 从系统中移除软件包。
    # adb shell pm uninstall --user "$user" "$package"
    do_cmd "pm uninstall --user "$user" "$package"" "对用户 $user 软件包 $package 卸载..." || state=1
    return $state
}


function handle_user() {
    local user="$1"
    local retainJoyose="$2"
    # 结果计数
    local num_ok=0
    local num_err=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ "$retainJoyose" != "0" && "$retainJoyose" != "1" ]] && return 1
    echo ""
    echo ""
    echo ""
    echo ""
    echo "处理用户 $user ..."
    {
        uninstall_updates "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        uninstall_updates "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        # uninstall_updates "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        stop "$user" "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        stop "$user" "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        stop "$user" "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable "$user" "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable "$user" "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable "$user" "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable_u "$user" "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable_u "$user" "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        disable_u "$user" "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        clear "$user" "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        clear "$user" "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        clear "$user" "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        for permission in "${PERMISSIONS[@]}"
        do
            revoke "$user" "$PKG_ADSOLUTION" "$permission"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
            revoke "$user" "$PKG_ANALYTICS" "$permission"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
            revoke "$user" "$PKG_JOYOSE" "$permission"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        done
        uninstall "$user" "$PKG_ADSOLUTION"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        uninstall "$user" "$PKG_ANALYTICS"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1)
        [[ "$retainJoyose" == "0" ]] && { uninstall "$user" "$PKG_JOYOSE"        && num_ok=$(expr $num_ok + 1) || num_err=$(expr $num_err + 1); } || echo "对用户 $user 跳过卸载 Joyose。"
    }
    echo "用户 $user 所有操作全部完成。以下是统计信息："
    echo "$num_ok 成功 / $num_err 失败。"
    echo ""
    echo "--------------------------------"
    echo ""
    return $num_ok
}





# ================================操作逻辑部分================================


echo ""
echo "################################"
echo "列出系统中的所有用户："
pm list users
users=($(pm list users | grep 'UserInfo' | sed 's/UserInfo{//g' | sed 's/:/ /g' | awk '{print $1}'))


# 列出各用户下存在的该死的软件包
for user in "${users[@]}"; do
    # echo **$user**
    echo ""
    list_malware "$user"
done


echo "################################"


# 调试模式下，暂停5秒
[[ "$IS_DEBUG_MODE" == "1" ]] && echo "" && echo "" && echo "调试模式，暂停5秒..." && sleep 5
# 创建日志文件夹
[[ -d "$LOG_DIR" ]] || mkdir -p "$LOG_DIR"
# 清理杂鱼：主用户保留Joyose（因为SIM卡密码存在里面），其余用户下全部清理掉
declare -A handle_user_result
for user in "${users[@]}"; do
    # echo **$user**
    # 0-主用户 10-分身用户 11-自建用户1 999-双开用户
    if [[ "$user" == "0" ]]; then
        handle_user "$user" "1"
        handle_user_result[$user]="$?"
        # 调试模式下，只处理主用户
        [[ "$IS_DEBUG_MODE" == "1" ]] && echo "调试模式，跳过其他用户的处理..." && break
    else
        handle_user "$user" "0"
        handle_user_result[$user]="$?"
    fi
done
log_info ""
log_info "所有用户所有操作全部完成。以下是统计信息："
for user in "${users[@]}"; do
    # echo **$user**
    log_info "- 用户 $user: \t${handle_user_result[$user]} 项成功"
done

echo ""
echo "【第一阶段结束】"
exit
