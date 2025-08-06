# Cursor Free VIP - 完整解决方案

解决Cursor编辑器"too many free trial accounts used on this machine"问题的完整自动化脚本。

## 🎯 功能特性

- ✅ **系统级机器ID重置** - 修改 `/etc/machine-id` 和 `/var/lib/dbus/machine-id`
- ✅ **应用级配置清除** - 清除所有Cursor配置和缓存
- ✅ **JS代码注入** - 绕过硬件指纹检测
- ✅ **自动化流程** - 一键完成所有修复步骤
- ✅ **安全备份** - 自动备份重要系统文件
- ✅ **启动脚本** - 提供便捷的启动方式

## 📋 系统要求

- Linux系统 (Ubuntu/Debian/CentOS等)
- sudo权限
- 已下载的Cursor AppImage文件
- 基础工具: `openssl`, `python3`, `sudo`

## 🚀 使用方法

### 0. 快速设置检查

```bash
# 运行项目设置脚本，检查文件是否正确放置
./setup_project.sh
```

### 1. 准备工作

⚠️ **重要：所有脚本文件必须与Cursor AppImage文件放在同一目录下！**

```bash
# 1. 创建工作目录
mkdir cursor_free_vip
cd cursor_free_vip

# 2. 将以下文件放入该目录：
#    - cursor_free_vip_complete.sh
#    - test_cursor_fix.sh
#    - README.md
#    - Cursor-1.3.9-x86_64.AppImage (需要下载)

# 3. 确认文件结构
ls -la
# 应该看到：
# cursor_free_vip_complete.sh
# test_cursor_fix.sh
# README.md
# Cursor-1.3.9-x86_64.AppImage

# 4. 验证AppImage文件
ls Cursor*.AppImage
```

### 2. 运行完整修复脚本

```bash
# 给脚本执行权限
chmod +x cursor_free_vip_complete.sh

# 运行修复脚本
./cursor_free_vip_complete.sh
```

### 3. 启动修改后的Cursor

```bash
# 重启系统 (推荐)
sudo reboot

# 启动方式1: 命令行启动
./cursor_free_launcher.sh

# 启动方式2: 应用程序菜单 (如果创建了桌面图标)
# 应用程序 -> 开发 -> Cursor Free VIP

# 启动方式3: 桌面快捷方式 (如果选择创建)
```

### 4. 桌面集成 (可选)

如果在修复过程中没有创建桌面图标，可以稍后手动创建：

```bash
# 创建桌面图标和应用程序菜单项
./create_desktop_entry.sh

# 卸载桌面集成 (如果需要)
./uninstall_cursor_free_vip.sh
```

## 🔧 脚本执行流程

1. **依赖检查** - 检查必要的系统工具
2. **文件检查** - 查找Cursor AppImage文件
3. **系统备份** - 备份重要系统文件
4. **进程停止** - 停止所有Cursor进程
5. **AppImage解压** - 解压AppImage文件
6. **系统修改** - 修改系统机器ID
7. **数据清除** - 清除所有Cursor数据
8. **配置重建** - 重新生成配置文件
9. **JS修改** - 注入绕过检测的代码
10. **启动脚本** - 创建便捷启动脚本

## 📁 项目文件结构

### 核心文件 (必需)
- `cursor_free_vip_complete.sh` - 主修复脚本
- `test_cursor_fix.sh` - 验证测试脚本
- `README.md` - 使用说明文档
- `Cursor-1.3.9-x86_64.AppImage` - Cursor安装包 (需要下载)

### 辅助文件
- `setup_project.sh` - 项目设置检查脚本
- `create_desktop_entry.sh` - 桌面图标创建脚本

### 运行后生成的文件
- `cursor_free_launcher.sh` - Cursor启动脚本
- `cursor_backup_YYYYMMDD_HHMMSS/` - 系统文件备份目录
- `squashfs-root/` - 解压的AppImage文件
- `uninstall_cursor_free_vip.sh` - 桌面集成卸载脚本 (如果创建了桌面图标)

## ⚠️ 重要说明

### 系统影响
- **修改系统机器ID可能影响其他软件的许可证验证**
- **建议在虚拟机或测试环境中使用**
- **脚本会自动备份原始文件，可手动恢复**

### 恢复方法
如需恢复原始系统设置：
```bash
# 恢复系统机器ID
sudo cp cursor_backup_*/machine-id.backup /etc/machine-id
sudo cp cursor_backup_*/dbus-machine-id.backup /var/lib/dbus/machine-id

# 恢复Cursor配置
cp -r cursor_backup_*/Cursor.backup ~/.config/Cursor
```

## 🛠️ 故障排除

### 如果仍然出现"too many"错误

1. **重启系统**
   ```bash
   sudo reboot
   ```

2. **更换网络环境**
   - 使用不同的WiFi网络
   - 使用手机热点
   - 使用VPN

3. **等待时间**
   - 等待24小时后再试
   - Cursor服务器可能有时间窗口限制

4. **清除浏览器缓存**
   - 如果Cursor使用了系统浏览器组件

### 常见问题

**Q: 脚本需要sudo权限吗？**
A: 是的，修改系统机器ID需要sudo权限。

**Q: 会影响其他软件吗？**
A: 可能会影响依赖机器ID的软件许可证，建议在测试环境使用。

**Q: 如何完全卸载？**
A: 删除生成的文件，使用备份恢复系统文件即可。

## 📝 技术原理

### 检测机制分析
Cursor使用多层检测机制：
1. **应用级机器码** - 存储在配置文件中
2. **系统级机器ID** - 读取系统文件
3. **硬件指纹** - CPU、内存、网络等信息
4. **网络指纹** - IP地址、请求特征等

### 绕过方法
1. **重置所有标识符** - 生成新的随机ID
2. **JS代码注入** - 重写硬件信息获取函数
3. **系统文件修改** - 更改系统级标识
4. **环境变量设置** - 覆盖运行时变量

## 📄 许可证

本项目仅供学习和研究使用，请遵守相关法律法规和软件许可协议。

## 🤝 贡献

欢迎提交Issue和Pull Request来改进这个项目。

---

**免责声明**: 本工具仅供教育和研究目的，使用者需自行承担使用风险。
