#!/data/data/com.termux/files/usr/bin/bash
# MIUI云控缓存清理工具
# @Updated 2025-10-24 01:37
# @Created 2025-10-23 13:53
# @Author Kei
# @Version 1.0.0-beta
# @Ref https://developer.android.google.cn/tools/adb?hl=zh-cn
# @Ref https://blog.csdn.net/weixin_40883833/article/details/133623434





# ================================基本功能及配置部分================================


# 配置项
PKG_ADSOLUTION="com.miui.systemAdSolution" # 智能服务（广告）
PKG_ANALYTICS="com.miui.analytics" # Analytics
PKG_JOYOSE="com.xiaomi.joyose" # Joyose
IS_DEBUG_MODE="1" # 是否处于调试模式
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
[[ "$IS_DEBUG_MODE" == "1" ]] && PERMISSIONS=( # 权限集
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
# 杂项配置，请勿修改
LOG_DIR="$(cd "$(dirname "$0")" && pwd)/log" # 日志文件夹
[[ "$IS_DEBUG_MODE" == "1" ]] && LOG_DIR="/storage/emulated/0/101o5_自用工具/fuck-joyose/log"
CURRENT_DATE=$(date +"%Y%m%d-%H%M%S")
# LOG_FILE="$LOG_DIR/fuck-joyose-log_${CURRENT_DATE}.log" # 日志文件
# ERR_LOG_FILE="$LOG_DIR/fuck-joyose-log-err_${CURRENT_DATE}.log" # 错误日志文件
LOG_FILE_STDOUT="$LOG_DIR/fuck-joyose_${CURRENT_DATE}_stdout.log" # 标准输出日志文件
LOG_FILE_STDERR="$LOG_DIR/fuck-joyose_${CURRENT_DATE}_stderr.log" # 标准错误日志文件
LOG_FILE_FULL="$LOG_DIR/fuck-joyose_${CURRENT_DATE}_full.log" # 完整日志文件





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
    echo "对用户 $user 软件包 $package 强行停止..."
    # 终止与 package 关联的所有进程。此命令仅终止可安全终止且不会影响用户体验的进程。
    # adb shell am kill --user "$user" "$package"
    # 强行停止与 package 关联的所有进程。
    # adb shell am force-stop --user "$user" "$package"
    am force-stop --user "$user" "$package" || state=1
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
    echo "对用户 $user 软件包 $package 撤销权限: $permission"
    # 从应用撤消权限。
    # 在搭载 Android 6.0（API 级别 23）及更高版本的设备上，该权限可以是应用清单中声明的任何权限。
    # 在搭载 Android 5.1（API 级别 22）及更低版本的设备上，该权限必须是应用定义的可选权限。
    # adb shell pm revoke --user "$user" "$package" "$permission"
    pm revoke --user "$user" "$package" "$permission" || state=1
    return $state
}


function clear() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    echo "对用户 $user 软件包 $package 清除数据..."
    # 删除与软件包关联的所有数据。
    # adb shell pm clear --user "$user" "$package"
    pm clear --user "$user" "$package" || state=1
    return $state
}


function disable() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    echo "对用户 $user 软件包 $package 停用..."
    # 停用给定的软件包或组件（写为“package/class”）。
    # adb shell pm disable --user "$user" "$package"
    # adb shell pm disable-user --user "$user" "$package"
    pm disable --user "$user" "$package" || state=1
    pm disable-user --user "$user" "$package" || state=1
    return $state
}


function uninstall_updates() {
    # local user="$1"
    local package="$1"
    local state=0
    # 如果未传入所需参数则返回错误代码
    # [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    echo "对软件包 $package 卸载更新..."
    # 卸载更新并还原至出厂版本。
    # adb shell pm uninstall-system-updates "$package"
    pm uninstall-system-updates "$package" || state=1
    return $state
}


function uninstall() {
    local user="$1"
    local package="$2"
    local state=0
    # 如果未传入所需参数则返回错误代码
    [[ -z "$user" ]] && return 1
    [[ -z "$package" ]] && return 1
    echo "对用户 $user 软件包 $package 卸载..."
    # 从系统中移除软件包。
    # adb shell pm uninstall --user "$user" "$package"
    pm uninstall --user "$user" "$package" || state=1
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
    # {
        uninstall_updates "$PKG_ADSOLUTION"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        uninstall_updates "$PKG_ANALYTICS"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        # uninstall_updates "$PKG_JOYOSE"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        # stop "$user" "$PKG_ADSOLUTION"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        # stop "$user" "$PKG_ANALYTICS"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        # stop "$user" "$PKG_JOYOSE"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        disable "$user" "$PKG_ADSOLUTION"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        disable "$user" "$PKG_ANALYTICS"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        disable "$user" "$PKG_JOYOSE"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        clear "$user" "$PKG_ADSOLUTION"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        clear "$user" "$PKG_ANALYTICS"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        clear "$user" "$PKG_JOYOSE"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        for permission in "${PERMISSIONS[@]}"
        do
            revoke "$user" "$PKG_ADSOLUTION" "$permission"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
            revoke "$user" "$PKG_ANALYTICS" "$permission"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
            revoke "$user" "$PKG_JOYOSE" "$permission"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        done
        uninstall "$user" "$PKG_ADSOLUTION"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        uninstall "$user" "$PKG_ANALYTICS"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }
        [[ "$retainJoyose" == "0" ]] && { uninstall "$user" "$PKG_JOYOSE"        && { num_ok=$(expr $num_ok + 1); echo "✅"; } || { num_err=$(expr $num_err + 1); echo "❌"; }; } || echo "对用户 $user 跳过卸载 Joyose。"
    # } 2>"$ERR_LOG_FILE"
    echo "用户 $user 所有操作全部完成。以下是统计信息："
    echo "$num_ok 成功 / $num_err 失败。"
    echo ""
    echo "--------------------------------"
    echo ""
    return 0
}





# ================================操作逻辑部分================================


echo ""
echo "################################"
echo "列出系统中的所有用户："
pm list users
sleep 5


echo ""
# echo "列出各用户下存在的该死的软件包："
list_malware "0"
echo ""
list_malware "10"
echo ""
list_malware "11"
echo ""
list_malware "999"
echo "################################"


echo ""
mkdir -p "$LOG_DIR"
echo "" > "$LOG_FILE_STDOUT"
# echo "" > "$LOG_FILE_STDERR"
# echo "" > "$LOG_FILE_FULL"
# 清理杂鱼：主用户保留Joyose（因为SIM卡密码存在里面），其余用户下全部清理掉
# 主用户
# handle_user "0" "1" > >(tee -a "$LOG_FILE_STDOUT" >> "$LOG_FILE_FULL") 2> >(tee -a "$LOG_FILE_STDERR" >> "$LOG_FILE_FULL")
handle_user "0" "1" 2>/dev/null | tee -a "$LOG_FILE_STDOUT"
[[ "$IS_DEBUG_MODE" == "1" ]] && echo "调试模式，跳过其他用户的处理..." && echo "【第一阶段结束】" && exit
# 分身用户
handle_user "10" "0" 2>/dev/null | tee -a "$LOG_FILE_STDOUT"
# 自建用户1
handle_user "11" "0" 2>/dev/null | tee -a "$LOG_FILE_STDOUT"
# 双开用户
handle_user "999" "0" 2>/dev/null | tee -a "$LOG_FILE_STDOUT"


echo ""
echo "【第一阶段结束】"
exit
