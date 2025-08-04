#!/bin/bash

# OracleLinux8.tar.gz ファイルの存在確認
if [ ! -f ./src/OracleLinux8/OracleLinux8.tar.gz ]; then
    echo "Warning: 'OracleLinux8.tar.gz' does not exist. Exiting script."
    exit 1
fi

# 既存のコンテナを停止
source ./stop-pod.sh

# 旧イメージの削除
podman rmi oracle_linux:8 1>/dev/null 2>/dev/null || true
echo "Clean old container successfully."

# イメージをビルド
echo "Building image..."
podman build -t oracle_linux:8 ./src/OracleLinux8/

echo "Container built successfully."
