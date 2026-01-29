#!/bin/bash

# =================================================================
# 脚本名称: merge_image.sh
# 描述: 使用 podman 自动合并 amd64 和 arm64 镜像为统一多架构 Manifest
# =================================================================

# 参数校验
if [ "$#" -ne 3 ]; then
    echo "用法: $0 <目标镜像> <AMD64源镜像> <ARM64源镜像>"
    echo "示例: $0 harbor.com/app:v1 harbor.com/app-amd:v1 harbor.com/app-arm:v1"
    exit 1
fi

TARGET=$1
AMD_SRC=$2
ARM_SRC=$3
TMP_NAME="merge_$(date +%s)"

echo "🚀 开始合并流程..."
echo "📍 目标镜像: $TARGET"
echo "🔍 源(AMD): $AMD_SRC"
echo "🔍 源(ARM): $ARM_SRC"

# 捕获错误，确保中间报错能退出
set -e

# 1. 创建本地清单
echo "📦 1/4 创建临时清单 $TMP_NAME..."
podman manifest create "$TMP_NAME"

# 2. 添加 AMD64 镜像
echo "➕ 2/4 添加 AMD64 架构..."
podman manifest add --tls-verify=false "$TMP_NAME" "docker://$AMD_SRC"

# 3. 添加 ARM64 镜像
echo "➕ 3/4 添加 ARM64 架构..."
podman manifest add --tls-verify=false "$TMP_NAME" "docker://$ARM_SRC"

# 4. 推送并清理
echo "⬆️  4/4 推送多架构镜像至仓库 (跳过 TLS 校验)..."
podman manifest push --tls-verify=false --all "$TMP_NAME" "docker://$TARGET"

echo "🧹 清理本地临时清单..."
podman manifest rm "$TMP_NAME"

echo "✅ 合并完成！"

# 验证输出 (可选)
echo "🧐 验证结果:"
podman manifest inspect --tls-verify=false "$TARGET"
