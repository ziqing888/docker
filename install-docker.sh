#!/bin/bash

# 文件名：install-docker.sh
# 描述：脚本用于在 Ubuntu 上安装最新版本的 Docker CE 和 Docker Compose v2。

set -e

# 输出信息函数
echo_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

# 检查是否已安装 Docker
check_docker_installed() {
    if command -v docker &> /dev/null; then
        echo_info "Docker 已安装，跳过安装步骤。"
        exit 0
    fi
}

# 检查是否已安装 Docker Compose
check_docker_compose_installed() {
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        echo_info "Docker Compose 已安装，跳过安装步骤。"
        exit 0
    fi
}

# 环境检查
echo_info "开始检查环境..."
check_docker_installed
check_docker_compose_installed

echo_info "开始安装 Docker 和 Docker Compose..."

# 更新系统并安装必要依赖
echo_info "更新系统并安装必要依赖..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# 添加 Docker 的 GPG 密钥
echo_info "添加 Docker 的 GPG 密钥..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# 添加 Docker 的软件源
echo_info "添加 Docker 的软件源..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 更新系统并安装 Docker
echo_info "安装 Docker..."
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin

# 安装 Docker Compose 插件（备用）
echo_info "安装 Docker Compose 插件..."
sudo apt-get install -y docker-compose-plugin

# 获取 Docker Compose 最新版本并安装
echo_info "下载并安装最新版本的 Docker Compose..."
DOCKER_COMPOSE_VERSION=$(curl -fsSL https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 为 Docker Compose 授予执行权限
echo_info "为 Docker Compose 授予执行权限..."
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
echo_info "验证 Docker 和 Docker Compose 的安装..."
docker --version
docker compose version

# 完成安装
echo_info "Docker 和 Docker Compose 安装完成！"
