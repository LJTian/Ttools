#!/bin/bash

# ==============================================================
# 统信 UOS / CentOS / openEuler / Ubuntu LVM 根目录一键扩容脚本
# 特性：自动检测并安装缺失命令 (growpart, lvm2) + 绕过中文报错
# ==============================================================

# 1. 必须以 root 权限运行检测
if [ "$EUID" -ne 0 ]; then
  echo "❌ 错误: 此脚本需要 root 权限才能执行磁盘操作和安装软件。"
  echo "请使用 sudo ./expand_disk_auto.sh 运行。"
  exit 1
fi

# 2. 定义目标设备变量
DISK="/dev/vda"
PART_NUM="3"
PART_PATH="${DISK}${PART_NUM}"       # 结果为 /dev/vda3
LV_PATH="/dev/mapper/uos-root"       # 您的逻辑卷路径

echo "====================================="
echo " 🚀 初始化 LVM 自动扩容程序..."
echo " 目标磁盘: ${DISK}"
echo " 目标分区: ${PART_PATH}"
echo " 目标 LVM: ${LV_PATH}"
echo "====================================="

# 3. 依赖检查与自动安装函数
install_dependency() {
    local cmd_name=$1
    local apt_pkg=$2
    local yum_pkg=$3

    if ! command -v "$cmd_name" &> /dev/null; then
        echo "⚠️  检测到缺少命令: ${cmd_name}，正在尝试自动安装..."
        
        if command -v apt-get &> /dev/null; then
            echo "   -> 使用 apt 包管理器安装 ${apt_pkg}..."
            apt-get update -yqq && apt-get install -y "$apt_pkg"
        elif command -v dnf &> /dev/null; then
            echo "   -> 使用 dnf 包管理器安装 ${yum_pkg}..."
            dnf install -y "$yum_pkg"
        elif command -v yum &> /dev/null; then
            echo "   -> 使用 yum 包管理器安装 ${yum_pkg}..."
            yum install -y "$yum_pkg"
        else
            echo "❌ 致命错误: 未找到支持的包管理器 (apt/yum/dnf)，无法自动安装 ${cmd_name}！"
            exit 1
        fi
        
        # 再次检查是否安装成功
        if ! command -v "$cmd_name" &> /dev/null; then
            echo "❌ 自动安装失败，请手动安装后重试。"
            exit 1
        fi
        echo "✅ ${cmd_name} 安装成功！"
    fi
}

# 4. 执行依赖检查
# 检查 growpart (Debian系叫 cloud-guest-utils，红帽系叫 cloud-utils-growpart)
install_dependency "growpart" "cloud-guest-utils" "cloud-utils-growpart"
# 检查 lvextend/pvresize (属于 lvm2 核心包)
install_dependency "lvextend" "lvm2" "lvm2"

echo "====================================="
echo " 🛠️ 依赖检查完毕，开始执行扩容..."

# 5. 扩容底层物理分区 (使用 LC_ALL=C 绕过 sfdisk 中文报错)
echo "[1/3] 尝试扩容物理分区 ${PART_PATH}..."
LC_ALL=C growpart ${DISK} ${PART_NUM} || echo " -> 提示: 分区可能已是最大容量，或已扩容完毕，继续执行下一步。"

# 6. 扩容 LVM 物理卷 (PV)
echo "[2/3] 刷新 LVM 物理卷容量..."
pvresize ${PART_PATH} || true

# 7. 扩容 LVM 逻辑卷 (LV) 并自动扩展文件系统 (-r 参数)
echo "[3/3] 扩容逻辑卷并拉伸文件系统..."
lvextend -l +100%FREE -r ${LV_PATH}

echo "====================================="
echo " 🎉 扩容任务执行完毕！当前系统空间状态："
df -h | grep -E "Filesystem|${LV_PATH}"
echo "====================================="
