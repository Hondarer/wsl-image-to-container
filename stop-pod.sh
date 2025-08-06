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

# 既存のコンテナを停止・削除
podman stop ${CONTAINER_NAME}_1 1>/dev/null 2>/dev/null || true
podman rm ${CONTAINER_NAME}_1 1>/dev/null 2>/dev/null || true

echo "Container stopped successfully."
