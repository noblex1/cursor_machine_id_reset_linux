#!/bin/bash

# Cursor Free VIP 测试脚本
# 用于验证修复是否成功

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "========================================"
echo "🧪 Cursor Free VIP 修复验证测试"
echo "========================================"
echo

# 测试1: 检查系统机器ID是否已修改
print_test "检查系统机器ID..."
current_machine_id=$(cat /etc/machine-id 2>/dev/null)
if [ "$current_machine_id" != "6b141d9d07b045e9bf55075b37dcefe3" ]; then
    print_pass "系统机器ID已修改: $current_machine_id"
else
    print_fail "系统机器ID未修改，仍为原始值"
fi

# 测试2: 检查Cursor配置是否已清除
print_test "检查Cursor配置..."
if [ ! -d "$HOME/.config/Cursor" ] || [ ! -f "$HOME/.config/Cursor/machineid" ]; then
    print_warn "Cursor配置不存在或不完整"
else
    cursor_machine_id=$(cat "$HOME/.config/Cursor/machineid" 2>/dev/null)
    print_pass "Cursor机器ID: $cursor_machine_id"
fi

# 测试3: 检查AppImage是否已解压
print_test "检查AppImage解压..."
if [ -d "squashfs-root" ]; then
    print_pass "AppImage已解压"
else
    print_fail "AppImage未解压"
fi

# 测试4: 检查JS文件是否已修改
print_test "检查JS文件修改..."
main_js="squashfs-root/usr/share/cursor/resources/app/out/main.js"
if [ -f "$main_js" ]; then
    if grep -q "Cursor Ultimate Free VIP" "$main_js"; then
        print_pass "JS补丁已注入"
    else
        print_fail "JS补丁未注入"
    fi
else
    print_fail "main.js文件不存在"
fi

# 测试5: 检查启动脚本是否存在
print_test "检查启动脚本..."
if [ -f "cursor_free_launcher.sh" ] && [ -x "cursor_free_launcher.sh" ]; then
    print_pass "启动脚本已创建"
else
    print_fail "启动脚本不存在或无执行权限"
fi

# 测试6: 检查备份文件
print_test "检查备份文件..."
backup_dirs=$(ls -d cursor_backup_* 2>/dev/null | wc -l)
if [ "$backup_dirs" -gt 0 ]; then
    print_pass "找到 $backup_dirs 个备份目录"
else
    print_warn "未找到备份目录"
fi

# 测试7: 检查Cursor进程
print_test "检查Cursor进程..."
if pgrep -f "cursor" > /dev/null; then
    print_warn "发现运行中的Cursor进程"
    ps aux | grep -i cursor | grep -v grep | head -3
else
    print_pass "没有运行中的Cursor进程"
fi

echo
echo "========================================"
echo "📊 测试总结"
echo "========================================"

# 计算修复完成度
total_tests=7
passed_tests=0

# 重新检查关键项目
[ "$current_machine_id" != "6b141d9d07b045e9bf55075b37dcefe3" ] && ((passed_tests++))
[ -d "squashfs-root" ] && ((passed_tests++))
[ -f "$main_js" ] && grep -q "Cursor Ultimate Free VIP" "$main_js" && ((passed_tests++))
[ -f "cursor_free_launcher.sh" ] && [ -x "cursor_free_launcher.sh" ] && ((passed_tests++))
[ -f "$HOME/.config/Cursor/machineid" ] && ((passed_tests++))
[ "$backup_dirs" -gt 0 ] && ((passed_tests++))
[ ! $(pgrep -f "cursor") ] && ((passed_tests++))

completion_rate=$((passed_tests * 100 / total_tests))

echo "修复完成度: $passed_tests/$total_tests ($completion_rate%)"

if [ "$completion_rate" -ge 80 ]; then
    echo -e "${GREEN}✅ 修复状态: 良好${NC}"
    echo "建议: 运行 ./cursor_free_launcher.sh 启动Cursor"
elif [ "$completion_rate" -ge 60 ]; then
    echo -e "${YELLOW}⚠️  修复状态: 部分完成${NC}"
    echo "建议: 重新运行完整修复脚本"
else
    echo -e "${RED}❌ 修复状态: 需要重新修复${NC}"
    echo "建议: 运行 ./cursor_free_vip_complete.sh"
fi

echo
echo "========================================"
echo "🔧 快速修复命令"
echo "========================================"
echo "完整修复: ./cursor_free_vip_complete.sh"
echo "启动Cursor: ./cursor_free_launcher.sh"
echo "查看日志: journalctl -f | grep cursor"
echo "重启系统: sudo reboot"
echo
