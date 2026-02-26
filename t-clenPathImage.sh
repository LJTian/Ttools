# 定义要去掉的前缀
PREFIX="m.daocloud.io/docker.io/library/"

# 找出所有带有该前缀的镜像并遍历处理
docker images --format "{{.Repository}}:{{.Tag}}" | grep "^${PREFIX}" | while read -r old_image; do
    # 截取掉前缀，生成新的镜像名 (例如 python:latest)
    new_image=${old_image#$PREFIX}
    
    echo "🔄 正在重命名: $old_image  ➜  $new_image"
    
    # 打上新标签
    docker tag "$old_image" "$new_image"
    
    # 删除旧标签（不会删除实际的镜像文件，只是删掉旧名字）
    docker rmi "$old_image" > /dev/null 2>&1
done

echo "✅ 清理完成！当前的镜像列表如下："
docker images
