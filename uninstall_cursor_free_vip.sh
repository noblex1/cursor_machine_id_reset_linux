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
