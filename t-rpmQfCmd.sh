#/bin/bash

# rpm_qf_cmd sed
# ceho sed-4.8-6.0.1.uelc20.01.x86_64

# 检查是否提供了参数
if [ -z "$1" ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

# 使用 whereis 查找文件
file_path=$(whereis "$1" | awk '{ print $2 }')

# 检查 whereis 是否找到了文件
if [ -z "$file_path" ]; then
    echo "Error: '$1' command not found."
    exit 1
fi

# 使用 rpm 查询文件所属的包
package_info=$(rpm -qf "$file_path" 2>/dev/null)

# 检查 rpm 是否成功
if [ $? -ne 0 ]; then
    echo "Error: Unable to determine package for '$file_path'."
    exit 1
fi

# 输出包信息
echo "Package for '$file_path': $package_info"

