#!/bin/bash

if [ -z "$1" ]; then
    echo "请输入要扫描的 IP 段，例如："
    echo "bash ping_scan.sh 192.168.1"
    exit 1
fi

base_ip="$1."

unreachable_ips=()

for i in {1..254}; do
    ip="$base_ip$i"
    {
        if ! ping -c 1 -W 1 $ip &> /dev/null; then
            echo "$ip 无法连接"
        fi
    } &
done

wait

echo "扫描完成。"

