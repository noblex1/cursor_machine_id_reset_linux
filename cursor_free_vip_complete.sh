#!/bin/bash

# Cursor Free VIP - 完整自动化脚本
# 解决 "too many free trial accounts" 问题
# 支持Linux系统

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo -e "${PURPLE}======================================================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}======================================================================${NC}"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# 检查依赖
check_dependencies() {
    print_step "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查必要的命令
    for cmd in openssl python3 sudo; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "缺少必要的依赖: ${missing_deps[*]}"
        print_info "请安装缺少的依赖后重新运行脚本"
        exit 1
    fi
    
    print_success "所有依赖检查通过"
}

# 检查AppImage文件
check_appimage() {
    print_step "检查Cursor AppImage文件..." >&2

    local appimage_file=""

    # 查找Cursor AppImage文件
    for file in Cursor*.AppImage cursor*.AppImage; do
        if [ -f "$file" ]; then
            appimage_file="$file"
            break
        fi
    done

    if [ -z "$appimage_file" ]; then
        print_error "未找到Cursor AppImage文件" >&2
        print_error "请确保以下文件在当前目录中：" >&2
        print_info "  - cursor_free_vip_complete.sh (本脚本)" >&2
        print_info "  - Cursor-1.3.9-x86_64.AppImage (需要下载)" >&2
        print_info "  - test_cursor_fix.sh (可选)" >&2
        echo >&2
        print_info "当前目录内容：" >&2
        ls -la *.sh *.AppImage 2>/dev/null >&2 || echo "  (未找到相关文件)" >&2
        echo >&2
        print_info "请下载Cursor AppImage文件到当前目录后重新运行" >&2
        exit 1
    fi

    print_success "找到AppImage文件: $appimage_file" >&2
    echo "$appimage_file"
}

# 解压AppImage
extract_appimage() {
    local appimage_file="$1"
    print_step "解压AppImage文件..."
    
    if [ -d "squashfs-root" ]; then
        print_warning "发现已存在的解压目录，正在清理..."
        rm -rf squashfs-root
    fi
    
    chmod +x "$appimage_file"
    ./"$appimage_file" --appimage-extract > /dev/null 2>&1
    
    if [ ! -d "squashfs-root" ]; then
        print_error "AppImage解压失败"
        exit 1
    fi
    
    print_success "AppImage解压完成"
}

# 停止Cursor进程
stop_cursor() {
    print_step "停止所有Cursor进程..."

    # 临时禁用set -e以避免pkill命令导致脚本退出
    set +e

    if pgrep -f "Cursor.*AppImage\|cursor.*AppImage\|\/usr\/share\/cursor\|\.cursor-server" > /dev/null 2>&1; then
        print_warning "发现运行中的Cursor进程，正在停止..."
        pkill -f "Cursor.*AppImage\|cursor.*AppImage\|\/usr\/share\/cursor\|\.cursor-server" > /dev/null 2>&1 || true
        sleep 2

        # 强制停止
        if pgrep -f "Cursor.*AppImage\|cursor.*AppImage\|\/usr\/share\/cursor\|\.cursor-server" > /dev/null 2>&1; then
            print_warning "正在强制停止剩余进程..."
            pkill -9 -f "Cursor.*AppImage\|cursor.*AppImage\|\/usr\/share\/cursor\|\.cursor-server" > /dev/null 2>&1 || true
            sleep 1
        fi

        # 最终检查
        if ! pgrep -f "Cursor.*AppImage\|cursor.*AppImage\|\/usr\/share\/cursor\|\.cursor-server" > /dev/null 2>&1; then
            print_success "所有Cursor进程已成功停止"
        else
            print_warning "部分Cursor进程可能仍在运行，但将继续执行"
        fi
    else
        print_info "未发现运行中的Cursor进程"
    fi

    # 重新启用set -e
    set -e

    print_success "Cursor进程停止步骤完成"
}

# 备份系统文件
backup_system_files() {
    print_step "备份系统文件..." >&2
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="cursor_backup_$timestamp"
    
    mkdir -p "$backup_dir"
    
    # 备份系统机器ID
    if [ -f "/etc/machine-id" ]; then
        sudo cp /etc/machine-id "$backup_dir/machine-id.backup"
    fi
    
    if [ -f "/var/lib/dbus/machine-id" ]; then
        sudo cp /var/lib/dbus/machine-id "$backup_dir/dbus-machine-id.backup"
    fi
    
    # 备份Cursor配置
    if [ -d "$HOME/.config/Cursor" ]; then
        cp -r "$HOME/.config/Cursor" "$backup_dir/Cursor.backup" 2>/dev/null || true
    fi
    
    print_success "系统文件已备份到: $backup_dir" >&2
    echo "$backup_dir"
}

# 修改系统机器ID
modify_system_machine_id() {
    print_step "修改系统机器ID..."
    
    # 生成新的机器ID
    local new_machine_id=$(openssl rand -hex 16)
    
    print_info "新机器ID: $new_machine_id"
    
    # 修改/etc/machine-id
    if [ -f "/etc/machine-id" ]; then
        echo "$new_machine_id" | sudo tee /etc/machine-id > /dev/null
        print_success "已更新 /etc/machine-id"
    fi
    
    # 修改/var/lib/dbus/machine-id
    if [ -f "/var/lib/dbus/machine-id" ]; then
        echo "$new_machine_id" | sudo tee /var/lib/dbus/machine-id > /dev/null
        print_success "已更新 /var/lib/dbus/machine-id"
    fi
    
    echo "$new_machine_id"
}

# 清除Cursor数据
clear_cursor_data() {
    print_step "清除所有Cursor数据..."
    
    # 删除配置目录
    local dirs_to_remove=(
        "$HOME/.config/Cursor"
        "$HOME/.config/cursor"
        "$HOME/.cursor-server"
        "$HOME/.cache/cursor"
        "$HOME/.cache/Cursor"
        "$HOME/.local/share/cursor"
        "$HOME/.local/share/Cursor"
    )
    
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "$dir" ]; then
            rm -rf "$dir"
            print_success "已删除: $dir"
        fi
    done
    
    # 清除临时文件
    find /tmp -name "*cursor*" -type f 2>/dev/null | while read -r file; do
        if [ -w "$file" ]; then
            rm -f "$file"
        fi
    done
    
    print_success "Cursor数据清除完成"
}

# 重新创建Cursor配置
recreate_cursor_config() {
    print_step "重新创建Cursor配置..."
    
    # 创建配置目录
    mkdir -p "$HOME/.config/Cursor/Crashpad"
    mkdir -p "$HOME/.config/Cursor/User/globalStorage"
    mkdir -p "$HOME/.cursor-server/data"
    
    # 生成新的ID
    local new_uuid=$(cat /proc/sys/kernel/random/uuid)
    local new_machine_id=$(openssl rand -hex 32)
    local new_mac_machine_id=$(openssl rand -hex 64)
    
    # 写入机器ID文件
    echo "$new_machine_id" > "$HOME/.config/Cursor/machineid"
    echo "$new_uuid" > "$HOME/.config/Cursor/Crashpad/client_id"
    echo "$new_uuid" > "$HOME/.cursor-server/data/machineid"
    
    # 创建storage.json
    cat > "$HOME/.config/Cursor/User/globalStorage/storage.json" << EOF
{
    "telemetry.devDeviceId": "$new_uuid",
    "telemetry.machineId": "$new_machine_id",
    "telemetry.macMachineId": "$new_mac_machine_id",
    "telemetry.sqmId": "",
    "storage.serviceMachineId": "$new_uuid"
}
EOF
    
    print_success "Cursor配置重新创建完成"
    print_info "新设备ID: $new_uuid"
    print_info "新机器ID: $new_machine_id"
}

# 修改JS文件
modify_js_files() {
    print_step "修改JS文件以绕过检测..."

    local main_js="squashfs-root/usr/share/cursor/resources/app/out/main.js"
    local workbench_js="squashfs-root/usr/share/cursor/resources/app/out/vs/workbench/workbench.desktop.main.js"

    # 检查文件是否存在
    if [ ! -f "$main_js" ]; then
        print_error "未找到main.js文件: $main_js"
        return 1
    fi

    # 备份原文件
    local timestamp=$(date +%Y%m%d_%H%M%S)
    cp "$main_js" "${main_js}.backup.${timestamp}"

    # 创建高级JS补丁
    cat > /tmp/cursor_patch.js << 'EOF'

// Cursor Ultimate Free VIP Injection
try {
    // 重写所有可能的硬件指纹获取函数
    const originalRequire = typeof require === "function" ? require : null;

    if (originalRequire) {
        // 重写crypto模块
        const crypto = originalRequire("crypto");
        if (crypto) {
            if (crypto.randomUUID) {
                crypto.randomUUID = function() {
                    return "12345678-1234-1234-1234-123456789abc";
                };
            }
            if (crypto.createHash) {
                const originalCreateHash = crypto.createHash;
                crypto.createHash = function(algorithm) {
                    const hash = originalCreateHash.call(this, algorithm);
                    const originalUpdate = hash.update;
                    hash.update = function(data) {
                        // 替换硬件相关的数据
                        if (typeof data === 'string' && (
                            data.includes('machine') ||
                            data.includes('device') ||
                            data.includes('hardware') ||
                            data.length === 32 || // 可能的机器ID
                            data.includes('-') && data.length === 36 // 可能的UUID
                        )) {
                            data = 'fixed-machine-identifier-12345';
                        }
                        return originalUpdate.call(this, data);
                    };
                    return hash;
                };
            }
        }

        // 重写os模块
        try {
            const os = originalRequire("os");
            if (os) {
                if (os.hostname) os.hostname = function() { return "cursor-free-host"; };
                if (os.userInfo) os.userInfo = function() { return {username: "cursor-user", homedir: "/home/cursor-user"}; };
                if (os.networkInterfaces) {
                    os.networkInterfaces = function() {
                        return {
                            eth0: [{
                                address: '192.168.1.100',
                                netmask: '255.255.255.0',
                                family: 'IPv4',
                                mac: '00:11:22:33:44:55',
                                internal: false
                            }]
                        };
                    };
                }
            }
        } catch(e) {}

        // 重写fs模块读取系统文件
        try {
            const fs = originalRequire("fs");
            if (fs && fs.readFileSync) {
                const originalReadFileSync = fs.readFileSync;
                fs.readFileSync = function(path, options) {
                    // 拦截系统机器ID文件读取
                    if (typeof path === 'string' && (
                        path.includes('/etc/machine-id') ||
                        path.includes('/var/lib/dbus/machine-id') ||
                        path.includes('machine-id')
                    )) {
                        return 'fixed-machine-id-12345678901234567890123456789012';
                    }
                    return originalReadFileSync.call(this, path, options);
                };
            }
        } catch(e) {}
    }

    // 重写全局变量
    if (typeof process !== "undefined") {
        if (process.env) {
            process.env.VSCODE_MACHINE_ID = "fixed-machine-id";
            process.env.MACHINE_ID = "fixed-machine-id";
            process.env.HOSTNAME = "cursor-free-host";
        }
    }

    // 重写全局函数
    if (typeof global !== "undefined") {
        global.getMachineId = function() { return "fixed-machine-id"; };
        global.getDeviceId = function() { return "fixed-device-id"; };
        global.macMachineId = "fixed-mac-machine-id";
        global.telemetryMachineId = "fixed-telemetry-id";
        global.getHardwareFingerprint = function() { return "fixed-hardware-fingerprint"; };
        global.getSystemUUID = function() { return "12345678-1234-1234-1234-123456789abc"; };
        global.getMACAddress = function() { return "00:11:22:33:44:55"; };
    }

    console.log("✅ Cursor Ultimate Free VIP patches applied successfully");

} catch(e) {
    console.log("❌ Cursor Ultimate Free VIP injection error:", e);
}
EOF

    # 检查是否已经注入过补丁
    if ! grep -q "Cursor Ultimate Free VIP" "$main_js"; then
        # 在文件开头注入补丁
        cat /tmp/cursor_patch.js "$main_js" > /tmp/main_js_patched
        mv /tmp/main_js_patched "$main_js"
        print_success "已注入JS补丁到main.js"
    else
        print_warning "JS补丁已存在，跳过注入"
    fi

    # 清理临时文件
    rm -f /tmp/cursor_patch.js

    print_success "JS文件修改完成"
}

# 创建启动脚本
create_launcher() {
    print_step "创建Cursor启动脚本..."

    cat > cursor_free_launcher.sh << 'EOF'
#!/bin/bash

# Cursor Free VIP 启动器
echo "🚀 启动Cursor Free VIP版本..."

# 检查修改后的文件是否存在
if [ ! -d "squashfs-root" ]; then
    echo "❌ 未找到解压的AppImage文件"
    echo "请先运行完整修复脚本"
    exit 1
fi

if [ ! -f "squashfs-root/usr/share/cursor/resources/app/out/main.js" ]; then
    echo "❌ 未找到修改后的main.js文件"
    echo "请先运行完整修复脚本"
    exit 1
fi

# 设置环境变量
export VSCODE_MACHINE_ID="fixed-machine-id"
export MACHINE_ID="fixed-machine-id"
export HOSTNAME="cursor-free-host"

echo "✅ 启动修改后的Cursor..."
cd squashfs-root
./AppRun --no-sandbox "$@"
EOF

    chmod +x cursor_free_launcher.sh
    print_success "启动脚本创建完成: cursor_free_launcher.sh"
    
    # 同时创建智能启动器到系统路径
    print_step "创建智能启动器..."
    
    mkdir -p "$HOME/.local/bin"
    
    cat > "$HOME/.local/bin/cursor-free-smart-launcher" << 'SMART_EOF'
#!/bin/bash

# Cursor Free VIP 智能启动器
# 自动寻找cursor项目目录并启动

echo "🔍 智能寻找Cursor Free VIP项目目录..."

# 可能的搜索路径列表
SEARCH_PATHS=(
    "$HOME/下载/cursor_reset_file"
    "$HOME/Downloads/cursor_reset_file"
    "$HOME/桌面/cursor_reset_file"
    "$HOME/Desktop/cursor_reset_file"
    "$HOME/cursor_reset_file"
    "/tmp/cursor_reset_file"
    "$HOME/下载/cursor_reset_file_backup"
    "$HOME/Downloads/cursor_reset_file_backup"
    "$(find $HOME -name "*cursor_reset_file*" -type d 2>/dev/null | head -1)"
    "$(find /home -name "*cursor_reset_file*" -type d 2>/dev/null | head -1)"
)

# 验证目录是否为有效的cursor项目目录
validate_cursor_dir() {
    local dir="$1"
    if [ -d "$dir/squashfs-root" ] && [ -f "$dir/cursor_free_launcher.sh" ] && [ -f "$dir/squashfs-root/usr/share/cursor/resources/app/out/main.js" ]; then
        return 0
    fi
    return 1
}

# 搜索有效的cursor目录
CURSOR_DIR=""
for path in "${SEARCH_PATHS[@]}"; do
    if [ -n "$path" ] && [ -d "$path" ]; then
        echo "🔍 检查路径: $path"
        if validate_cursor_dir "$path"; then
            CURSOR_DIR="$path"
            echo "✅ 找到有效的Cursor项目目录: $CURSOR_DIR"
            break
        fi
    fi
done

# 如果没找到，尝试更广泛的搜索
if [ -z "$CURSOR_DIR" ]; then
    echo "🔍 进行更广泛的搜索..."
    # 搜索包含cursor_free_launcher.sh的目录
    LAUNCHER_DIRS=$(find $HOME -name "cursor_free_launcher.sh" -type f 2>/dev/null)
    for launcher in $LAUNCHER_DIRS; do
        dir=$(dirname "$launcher")
        echo "🔍 检查找到的launcher目录: $dir"
        if validate_cursor_dir "$dir"; then
            CURSOR_DIR="$dir"
            echo "✅ 通过launcher找到Cursor项目目录: $CURSOR_DIR"
            break
        fi
    done
fi

# 如果还是没找到，显示错误信息
if [ -z "$CURSOR_DIR" ]; then
    echo "❌ 未找到有效的Cursor Free VIP项目目录！"
    echo "请确保以下文件存在："
    echo "  - cursor_reset_file/squashfs-root/"
    echo "  - cursor_reset_file/cursor_free_launcher.sh"
    echo "  - cursor_reset_file/squashfs-root/usr/share/cursor/resources/app/out/main.js"
    echo ""
    echo "或者手动指定目录: $0 /path/to/cursor_reset_file"
    exit 1
fi

# 如果用户提供了参数，使用用户指定的目录
if [ $# -gt 0 ] && [ -d "$1" ]; then
    if validate_cursor_dir "$1"; then
        CURSOR_DIR="$1"
        echo "✅ 使用用户指定目录: $CURSOR_DIR"
    else
        echo "❌ 用户指定的目录无效: $1"
        exit 1
    fi
fi

# 切换到项目目录并启动
echo "🚀 启动Cursor Free VIP..."
cd "$CURSOR_DIR"

# 设置环境变量
export VSCODE_MACHINE_ID="fixed-machine-id"
export MACHINE_ID="fixed-machine-id"
export HOSTNAME="cursor-free-host"

# 启动应用
echo "✅ 启动修改后的Cursor..."
cd squashfs-root
exec ./AppRun --no-sandbox "$@"
SMART_EOF

    chmod +x "$HOME/.local/bin/cursor-free-smart-launcher"
    print_success "智能启动器创建完成: ~/.local/bin/cursor-free-smart-launcher"
}

# 主函数
main() {
    print_header "🚀 Cursor Free VIP - 完整自动化脚本 🚀"

    print_warning "此脚本将执行以下操作:"
    echo "  1. 修改系统机器ID (需要sudo权限)"
    echo "  2. 清除所有Cursor数据和配置"
    echo "  3. 修改AppImage中的JS文件"
    echo "  4. 重新生成所有标识符"
    echo "  5. 创建启动脚本"
    echo
    print_warning "注意: 修改系统机器ID可能影响其他软件!"
    echo

    read -p "是否继续? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "操作已取消"
        exit 0
    fi

    echo
    print_info "开始执行修复流程..."
    echo

    # 执行修复步骤
    check_dependencies

    echo "DEBUG: 开始检查AppImage文件..."
    local appimage_file=$(check_appimage)
    echo "DEBUG: AppImage文件检查完成，文件: $appimage_file"

    echo "DEBUG: 开始备份系统文件..."
    local backup_dir=$(backup_system_files)
    echo "DEBUG: 系统文件备份完成，目录: $backup_dir"

    echo "DEBUG: 开始停止Cursor进程..."
    stop_cursor || true
    echo "DEBUG: Cursor进程停止完成"

    echo "DEBUG: 开始解压AppImage文件..."
    extract_appimage "$appimage_file"
    echo "DEBUG: AppImage解压完成"

    local new_machine_id=$(modify_system_machine_id)

    clear_cursor_data
    recreate_cursor_config
    modify_js_files
    create_launcher

    echo
    print_header "✅ 修复完成!"
    echo
    print_success "系统机器ID已更改为: $new_machine_id"
    print_success "备份文件保存在: $backup_dir"
    print_success "启动脚本: ./cursor_free_launcher.sh"
    echo

    # 询问是否创建桌面图标
    echo
    read -p "是否创建桌面图标和应用程序菜单项? (y/N): " create_desktop
    if [[ "$create_desktop" =~ ^[Yy]$ ]]; then
        if [ -f "create_desktop_entry.sh" ]; then
            echo
            print_info "正在创建桌面集成..."
            chmod +x create_desktop_entry.sh
            # 在子shell中运行，避免输出混乱
            (./create_desktop_entry.sh) || print_warning "桌面集成创建可能不完整"
        else
            print_warning "未找到 create_desktop_entry.sh 脚本"
            print_info "您可以稍后手动运行该脚本创建桌面图标"
        fi
    fi

    echo
    print_info "使用方法:"
    echo "  1. 重启系统 (推荐，确保所有更改生效)"
    echo "  2. 启动方式:"
    echo "     - 命令行: ./cursor_free_launcher.sh"
    if [[ "$create_desktop" =~ ^[Yy]$ ]]; then
        echo "     - 应用程序菜单: 开发 -> Cursor Free VIP"
        echo "     - 桌面快捷方式 (如果选择创建)"
    fi
    echo
    print_warning "如果仍有问题，可能需要:"
    echo "  - 更换网络环境或使用VPN"
    echo "  - 等待24小时后再试"
    echo "  - 清除浏览器缓存"
    echo
    print_info "备份文件位置: $backup_dir"
    print_info "如需恢复，请手动复制备份文件"
    echo
}

# 运行主函数
main "$@"
