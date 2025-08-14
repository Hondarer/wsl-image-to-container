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

echo "Building from: ${ROOT_FILENAME_WITH_EXT}"

# container-release の作成
echo "Build on $(LANG=C && date)" > ./src/container-release
echo "  from $(cd src && ls -l ${ROOT_FILENAME_WITH_EXT})" >> ./src/container-release

# ホストのユーザー情報を取得
USER_NAME=$(whoami)
#UID=$(id -u)
GID=$(id -g)

echo "Building with user info: USER_NAME=${USER_NAME}, UID=${UID}, GID=${GID}"

# 既存のコンテナを停止
source ./stop-pod.sh

# 旧イメージの削除
podman rmi ${CONTAINER_NAME} 1>/dev/null 2>/dev/null || true
echo "Clean old container successfully."

# イメージをビルド
echo "Building image..."
podman build -t ${CONTAINER_NAME} \
    --build-arg USER_NAME="${USER_NAME}" \
    --build-arg UID="${UID}" \
    --build-arg GID="${GID}" \
    --build-arg ROOT_FILENAME_WITH_EXT="${ROOT_FILENAME_WITH_EXT}" \
    ./src/

if [ $? -ne 0 ]; then
    echo "Error: Failed to build container."
    exit 1
fi

# 登録されたイメージの表示
podman images ${CONTAINER_NAME}

echo "Container built successfully."
