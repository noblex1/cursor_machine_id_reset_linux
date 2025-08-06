#!/bin/bash

# Cursor Free VIP 项目设置脚本
# 帮助用户正确组织文件结构

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

print_header "🚀 Cursor Free VIP 项目设置"

echo "此脚本将帮助您正确设置项目文件结构"
echo

# 检查当前目录中的文件
print_info "检查当前目录中的文件..."

# 检查脚本文件
scripts_found=0
required_scripts=("cursor_free_vip_complete.sh" "test_cursor_fix.sh")
optional_scripts=("create_desktop_entry.sh" "setup_project.sh")

for script in "${required_scripts[@]}"; do
    if [ -f "$script" ]; then
        print_success "找到: $script"
        ((scripts_found++))
    else
        print_warning "缺少: $script"
    fi
done

for script in "${optional_scripts[@]}"; do
    if [ -f "$script" ]; then
        print_success "找到: $script (可选)"
    fi
done

# 检查AppImage文件
appimage_found=0
for file in Cursor*.AppImage cursor*.AppImage; do
    if [ -f "$file" ]; then
        print_success "找到AppImage: $file"
        appimage_found=1
        break
    fi
done

if [ $appimage_found -eq 0 ]; then
    print_warning "未找到Cursor AppImage文件"
fi

# 检查README文件
if [ -f "README.md" ]; then
    print_success "找到: README.md"
else
    print_warning "缺少: README.md"
fi

echo
print_header "📋 文件状态总结"

if [ $scripts_found -eq 2 ] && [ $appimage_found -eq 1 ]; then
    print_success "✅ 所有必需文件都已就位！"
    echo
    print_info "您可以直接运行："
    echo "  ./cursor_free_vip_complete.sh"
    echo
elif [ $scripts_found -eq 2 ] && [ $appimage_found -eq 0 ]; then
    print_warning "⚠️  脚本文件已就位，但缺少AppImage文件"
    echo
    print_info "请下载Cursor AppImage文件到当前目录："
    echo "  1. 访问 https://cursor.sh/"
    echo "  2. 下载Linux版本的AppImage文件"
    echo "  3. 将文件放在当前目录中"
    echo "  4. 重新运行此设置脚本验证"
    echo
else
    print_error "❌ 文件设置不完整"
    echo
    print_info "需要的文件结构："
    echo "  cursor_free_vip/"
    echo "  ├── cursor_free_vip_complete.sh  (主修复脚本)"
    echo "  ├── test_cursor_fix.sh          (测试脚本)"
    echo "  ├── README.md                   (说明文档)"
    echo "  └── Cursor-1.3.9-x86_64.AppImage (需要下载)"
    echo
fi

# 显示当前目录内容
echo
print_info "当前目录内容："
ls -la *.sh *.md *.AppImage 2>/dev/null || echo "  (未找到相关文件)"

echo
print_header "🔧 下一步操作"

if [ $scripts_found -eq 2 ] && [ $appimage_found -eq 1 ]; then
    echo "1. 运行完整修复: ./cursor_free_vip_complete.sh"
    echo "2. 验证修复状态: ./test_cursor_fix.sh"
    echo "3. 启动Cursor: ./cursor_free_launcher.sh (修复后自动生成)"
else
    echo "1. 确保所有必需文件在当前目录中"
    echo "2. 重新运行此设置脚本: ./setup_project.sh"
    echo "3. 文件就位后运行: ./cursor_free_vip_complete.sh"
fi

echo
print_info "如需帮助，请查看 README.md 文件"
