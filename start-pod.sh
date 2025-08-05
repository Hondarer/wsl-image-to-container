#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接操作する

# 既存のコンテナを停止
source ./stop-pod.sh

# Check if the oracle_linux:8 image exists
if ! podman images | grep -q "oracle_linux.*8"; then
    source ./build-pod.sh
    #echo "Error: oracle_linux:8 image not found."
    #echo "Please ensure oracle_linux:8 is registered before running this script."
    #exit 1
fi

# ホストのユーザー情報を取得
USER_NAME=$(whoami)
#UID=$(id -u)
GID=$(id -g)

# ホスト側ディレクトリ準備
mkdir -p ./storage/OracleLinux8/1/home_${USER_NAME}
mkdir -p ./storage/OracleLinux8/1/workspace

# ~/.ssh/id_rsa.pub があれば、.ssh/authorized_keys に設定
if [ -f ~/.ssh/id_rsa.pub ] && [ ! -f ./storage/OracleLinux8/1/home_${USER_NAME}/.ssh/authorized_keys ]; then
    mkdir -p ./storage/OracleLinux8/1/home_${USER_NAME}/.ssh
    cp ~/.ssh/id_rsa.pub ./storage/OracleLinux8/1/home_${USER_NAME}/.ssh/authorized_keys
    # パーミッションの設定
    chmod 700 ./storage/OracleLinux8/1/home_${USER_NAME}/.ssh
    chmod 600 ./storage/OracleLinux8/1/home_${USER_NAME}/.ssh/authorized_keys
fi

# コンテナ起動 (UID マッピング)
echo "Starting container with keep-id userns..."
podman run -d \
    --name oracle_linux_8_1 \
    --userns=keep-id \
    -p 40022:22 \
    -v ./storage/OracleLinux8/1/home_${USER_NAME}:/home/${USER_NAME}:Z \
    -v ./storage/OracleLinux8/1/workspace:/workspace:Z \
    --restart unless-stopped \
    --env USER_NAME=${USER_NAME} \
    --env UID=${UID} \
    --env GID=${GID} \
    oracle_linux:8

echo "Container started successfully."

# 確認
echo -e "\n=== Container Info ==="
podman ps | grep oracle_linux_8_1

#echo -e "\n=== UID/GID Mapping Check ==="
#podman exec oracle_linux_8_1 id

#echo -e "\n=== File Permissions Check ==="
#podman exec oracle_linux_8_1 ls -la /workspace
