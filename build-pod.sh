#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接操作する

# OracleLinux8.tar.gz ファイルの存在確認
if [ ! -f ./src/OracleLinux8/OracleLinux8.tar.gz ]; then
    echo "Warning: 'OracleLinux8.tar.gz' does not exist. Exiting script."
    exit 1
fi

# ホストのユーザー情報を取得
USER_NAME=$(whoami)
#UID=$(id -u)
GID=$(id -g)

echo "Building with user info: USER_NAME=${USER_NAME}, UID=${UID}, GID=${GID}"

# 既存のコンテナを停止
source ./stop-pod.sh

# 旧イメージの削除
podman rmi oracle_linux:8 1>/dev/null 2>/dev/null || true
echo "Clean old container successfully."

# イメージをビルド
echo "Building image..."
podman build -t oracle_linux:8 \
    --build-arg USER_NAME="${USER_NAME}" \
    --build-arg UID="${UID}" \
    --build-arg GID="${GID}" \
    ./src/OracleLinux8/

if [ $? -ne 0 ]; then
    echo "Error: Failed to build container."
    exit 1
fi

echo "Container built successfully."
