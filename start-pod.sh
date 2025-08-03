#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接起動する

# 既存のコンテナを停止・削除
podman stop oracle_linux_8_1 2>/dev/null || true
podman rm oracle_linux_8_1 2>/dev/null || true

# ホスト側ディレクトリ準備
mkdir -p ./storage/oracle_linux_8/1/home_user
mkdir -p ./storage/oracle_linux_8/1/workspace

# イメージをビルド
echo "Building image..."
podman build -t oracle_linux:8 ./src/oracle_linux_8/

# コンテナ起動 (UID 1000 → 1000 マッピング)
echo "Starting container with keep-id userns..."
podman run -d \
  --name oracle_linux_8_1 \
  --userns=keep-id \
  -p 20001:22 \
  -v ./storage/oracle_linux_8/1/home_user:/home/user:Z \
  -v ./storage/oracle_linux_8/1/workspace:/workspace:Z \
  --restart unless-stopped \
  oracle_linux:8

echo "Container started successfully!"

# 確認
echo -e "\n=== Container Info ==="
podman ps | grep oracle_linux_8_1

#echo -e "\n=== UID/GID Mapping Check ==="
#podman exec oracle_linux_8_1 id

#echo -e "\n=== File Permissions Check ==="
#podman exec oracle_linux_8_1 ls -la /workspace
