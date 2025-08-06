#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接操作する

# アーカイブを特定する
ROOT_FILENAME_WITH_EXT=$(find ./src -type f \( -name "*.tar.gz" -o -name "*.tgz" \) \
    | sed -E 's/\.\/src\/(.*\/)?([^/]+)\.(tar\.gz|tgz)$/\2.\3/' \
    | sort -V | tail -n 1)

# ファイル名部分を切り出し
CONTAINER_NAME=$(echo "${ROOT_FILENAME_WITH_EXT}" | sed 's/\.\(tar\.gz\|tgz\)$//')
CONTAINER_NAME=$(echo "${CONTAINER_NAME}" | sed -E 's/([a-z])([A-Z])/\1_\2/g' | sed -E 's/([a-z])([0-9])/\1_\2/g' | tr '[:upper:]' '[:lower:]')

if [ -z "${ROOT_FILENAME_WITH_EXT}" ]; then
    echo "Warning: No .tar.gz or .tgz files found in './src'. Exiting script."
    exit 1
fi

# 既存のコンテナを停止
source ./stop-pod.sh

# Check if the container image exists
if ! podman images | grep -q "${CONTAINER_NAME}"; then
    source ./build-pod.sh
    #echo "Error: ${CONTAINER_NAME} image not found."
    #echo "Please ensure ${CONTAINER_NAME} is registered before running this script."
    #exit 1
fi

# ホストのユーザー情報を取得
USER_NAME=$(whoami)
#UID=$(id -u)
GID=$(id -g)

# ホスト側ディレクトリ準備
mkdir -p ./storage/1/home_${USER_NAME}
mkdir -p ./storage/1/workspace

# ~/.ssh/id_rsa.pub があれば、.ssh/authorized_keys に設定
if [ -f ~/.ssh/id_rsa.pub ] && [ ! -f ./storage/1/home_${USER_NAME}/.ssh/authorized_keys ]; then
    mkdir -p ./storage/1/home_${USER_NAME}/.ssh
    cp ~/.ssh/id_rsa.pub ./storage/1/home_${USER_NAME}/.ssh/authorized_keys
    # パーミッションの設定
    chmod 700 ./storage/1/home_${USER_NAME}/.ssh
    chmod 600 ./storage/1/home_${USER_NAME}/.ssh/authorized_keys
fi

# コンテナ起動 (UID マッピング)
echo "Starting container with keep-id userns..."
podman run -d \
    --name ${CONTAINER_NAME}_1 \
    --userns=keep-id \
    -p 40022:22 \
    -v ./storage/1/home_${USER_NAME}:/home/${USER_NAME}:Z \
    -v ./storage/1/workspace:/workspace:Z \
    --restart unless-stopped \
    --env USER_NAME=${USER_NAME} \
    --env UID=${UID} \
    --env GID=${GID} \
    ${CONTAINER_NAME}

if [ $? -ne 0 ]; then
    echo "Error: Failed to start container."
    exit 1
fi

echo "Container started successfully."

# 確認
echo -e "\n=== Container Info ==="
podman ps | grep ${CONTAINER_NAME}_1

#echo -e "\n=== UID/GID Mapping Check ==="
#podman exec ${CONTAINER_NAME}_1 id

#echo -e "\n=== File Permissions Check ==="
#podman exec ${CONTAINER_NAME}_1 ls -la /workspace
