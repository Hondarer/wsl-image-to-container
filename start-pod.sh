#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接起動する

# 既存のコンテナを停止
source ./stop-pod.sh

# Check if the oracle_linux:8 image exists
if ! podman images | grep -q "oracle_linux.*8"; then
    source ./build-pod.sh
    #echo "Error: oracle_linux:8 image not found."
    #echo "Please ensure oracle_linux:8 is registered before running this script."
    #exit 1
fi

# ホスト側ディレクトリ準備
mkdir -p ./storage/OracleLinux8/1/home_user
mkdir -p ./storage/OracleLinux8/1/workspace

# コンテナ起動 (UID 1000 → 1000 マッピング)
echo "Starting container with keep-id userns..."
podman run -d \
    --name oracle_linux_8_1 \
    --userns=keep-id \
    -p 20001:22 \
    -v ./storage/OracleLinux8/1/home_user:/home/user:Z \
    -v ./storage/OracleLinux8/1/workspace:/workspace:Z \
    --restart unless-stopped \
    oracle_linux:8

echo "Container started successfully."

# 確認
echo -e "\n=== Container Info ==="
podman ps | grep oracle_linux_8_1

#echo -e "\n=== UID/GID Mapping Check ==="
#podman exec oracle_linux_8_1 id

#echo -e "\n=== File Permissions Check ==="
#podman exec oracle_linux_8_1 ls -la /workspace
