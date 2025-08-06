#!/bin/bash

# Cursor Free VIP 桌面图标创建脚本
# 在应用程序菜单中创建Cursor Free VIP图标

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}======================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}======================================${NC}"
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

# 检查必要文件
check_requirements() {
    print_info "检查必要文件..."
    
    # 检查启动脚本
    if [ ! -f "cursor_free_launcher.sh" ]; then
        print_error "未找到 cursor_free_launcher.sh"
        print_info "请先运行 ./cursor_free_vip_complete.sh 完成修复"
        exit 1
    fi
    
    # 检查解压目录
    if [ ! -d "squashfs-root" ]; then
        print_error "未找到 squashfs-root 目录"
        print_info "请先运行 ./cursor_free_vip_complete.sh 完成修复"
        exit 1
    fi
    
    print_success "必要文件检查通过"
}

# 提取图标
extract_icon() {
    print_info "提取Cursor图标..." >&2
    
    local icon_path=""
    local icon_extracted=false
    
    # 查找图标文件
    local possible_icons=(
        "squashfs-root/usr/share/cursor/resources/app/resources/cursor.png"
        "squashfs-root/usr/share/cursor/resources/app/resources/icon.png"
        "squashfs-root/cursor.png"
        "squashfs-root/icon.png"
    )
    
    for icon in "${possible_icons[@]}"; do
        if [ -f "$icon" ]; then
            icon_path="$icon"
            icon_extracted=true
            break
        fi
    done
    
    # 如果没找到图标，从AppImage中提取
    if [ ! $icon_extracted ]; then
        print_info "从AppImage中提取图标..." >&2
        
        # 查找AppImage文件
        local appimage_file=""
        for file in Cursor*.AppImage cursor*.AppImage; do
            if [ -f "$file" ]; then
                appimage_file="$file"
                break
            fi
        done
        
        if [ -n "$appimage_file" ]; then
            # 尝试提取图标
            ./"$appimage_file" --appimage-extract "*.png" 2>/dev/null >&2 || true
            ./"$appimage_file" --appimage-extract "usr/share/icons/*" 2>/dev/null >&2 || true
            ./"$appimage_file" --appimage-extract "usr/share/pixmaps/*" 2>/dev/null >&2 || true
            
            # 再次查找提取的图标
            for icon in "${possible_icons[@]}"; do
                if [ -f "$icon" ]; then
                    icon_path="$icon"
                    icon_extracted=true
                    break
                fi
            done
        fi
    fi
    
    if [ $icon_extracted ]; then
        # 复制图标到用户图标目录
        local user_icon_dir="$HOME/.local/share/icons"
        mkdir -p "$user_icon_dir"
        
        cp "$icon_path" "$user_icon_dir/cursor-free-vip.png"
        print_success "图标已提取: $user_icon_dir/cursor-free-vip.png" >&2
        echo "$user_icon_dir/cursor-free-vip.png"
    else
        print_warning "未找到图标文件，将使用默认图标" >&2
        echo "text-editor"  # 返回默认图标名称
    fi
}

# 创建桌面文件
create_desktop_file() {
    print_info "创建桌面应用程序条目..."
    
    local icon_path="$1"
    local smart_launcher="$HOME/.local/bin/cursor-free-smart-launcher"
    
    # 确保应用程序目录存在
    local apps_dir="$HOME/.local/share/applications"
    mkdir -p "$apps_dir"
    
    # 创建桌面文件 - 使用智能启动器
    cat > "$apps_dir/cursor-free-vip.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor Free VIP
Comment=Cursor Code Editor (Free VIP Version)
GenericName=Code Editor
Exec=$smart_launcher %F
Icon=$icon_path
Terminal=false
NoDisplay=false
Categories=Development;IDE;TextEditor;
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/javascript;application/json;text/css;text/html;text/xml;
StartupNotify=true
StartupWMClass=cursor
Keywords=cursor;code;editor;development;programming;
EOF
    
    # 设置可执行权限
    chmod +x "$apps_dir/cursor-free-vip.desktop"
    
    print_success "桌面文件已创建: $apps_dir/cursor-free-vip.desktop"
    print_info "使用智能启动器: $smart_launcher"
}

# 创建桌面快捷方式
create_desktop_shortcut() {
    print_info "创建桌面快捷方式..."
    
    local icon_path="$1"
    local smart_launcher="$HOME/.local/bin/cursor-free-smart-launcher"
    
    # 检查桌面目录
    local desktop_dir=""
    if [ -d "$HOME/Desktop" ]; then
        desktop_dir="$HOME/Desktop"
    elif [ -d "$HOME/桌面" ]; then
        desktop_dir="$HOME/桌面"
    else
        print_warning "未找到桌面目录，跳过桌面快捷方式创建"
        return
    fi
    
    local desktop_file="$desktop_dir/cursor-free-vip.desktop"
    
    # 创建桌面快捷方式 - 使用智能启动器
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Cursor Free VIP
Comment=Cursor Code Editor (Free VIP Version)
GenericName=Code Editor
Exec=$smart_launcher %F
Icon=$icon_path
Terminal=false
Categories=Development;IDE;TextEditor;
StartupNotify=true
StartupWMClass=cursor
Keywords=cursor;code;editor;development;programming;
EOF
    
    # 设置可执行权限
    chmod +x "$desktop_file"
    
    print_success "桌面快捷方式已创建: $desktop_file"
    print_info "使用智能启动器: $smart_launcher"
}

# 更新应用程序数据库
update_desktop_database() {
    print_info "更新应用程序数据库..."
    
    # 更新桌面数据库
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        print_success "应用程序数据库已更新"
    else
        print_warning "update-desktop-database 命令不可用，跳过数据库更新"
    fi
    
    # 更新图标缓存
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache "$HOME/.local/share/icons" 2>/dev/null || true
        print_success "图标缓存已更新"
    else
        print_warning "gtk-update-icon-cache 命令不可用，跳过图标缓存更新"
    fi
}

# 创建卸载脚本
create_uninstall_script() {
    print_info "创建卸载脚本..."
    
    cat > uninstall_cursor_free_vip.sh << 'EOF'
#!/bin/bash

# Cursor Free VIP 卸载脚本

echo "🗑️  卸载Cursor Free VIP..."

# 删除桌面文件
rm -f "$HOME/.local/share/applications/cursor-free-vip.desktop"
echo "已删除应用程序菜单项"

# 删除桌面快捷方式
rm -f "$HOME/Desktop/Cursor Free VIP.desktop"
echo "已删除桌面快捷方式"

# 删除图标
rm -f "$HOME/.local/share/icons/cursor-free-vip.png"
echo "已删除图标文件"

# 更新数据库
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache "$HOME/.local/share/icons" 2>/dev/null || true
fi

echo "✅ Cursor Free VIP 桌面集成已卸载"
echo "注意: 这只会删除桌面图标，不会删除Cursor文件"
EOF
    
    chmod +x uninstall_cursor_free_vip.sh
    print_success "卸载脚本已创建: uninstall_cursor_free_vip.sh"
}

# 主函数
main() {
    print_header "🖥️  Cursor Free VIP 桌面集成"
    
    echo "此脚本将为Cursor Free VIP创建桌面图标和应用程序菜单项"
    echo
    
    # 检查必要文件
    check_requirements
    
    # 提取图标
    local icon_path=$(extract_icon)
    
    # 创建桌面文件
    create_desktop_file "$icon_path"
    
    # 询问是否创建桌面快捷方式
    echo
    read -p "是否在桌面创建快捷方式? (y/N): " create_shortcut
    if [[ "$create_shortcut" =~ ^[Yy]$ ]]; then
        create_desktop_shortcut "$icon_path"
    fi
    
    # 更新数据库
    update_desktop_database
    
    # 创建卸载脚本
    create_uninstall_script
    
    echo
    print_header "✅ 桌面集成完成!"
    
    print_success "Cursor Free VIP 现在可以从以下位置启动:"
    echo "  📱 应用程序菜单 -> 开发 -> Cursor Free VIP"
    if [[ "$create_shortcut" =~ ^[Yy]$ ]]; then
        echo "  🖥️  桌面快捷方式"
    fi
    echo "  🚀 命令行: ./cursor_free_launcher.sh"
    echo
    
    print_info "其他信息:"
    echo "  📁 桌面文件: ~/.local/share/applications/cursor-free-vip.desktop"
    echo "  🎨 图标文件: ~/.local/share/icons/cursor-free-vip.png"
    echo "  🗑️  卸载脚本: ./uninstall_cursor_free_vip.sh"
    echo
    
    print_warning "注意: 如果图标没有立即显示，请注销并重新登录"
}

# 运行主函数
main "$@"
