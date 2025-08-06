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
