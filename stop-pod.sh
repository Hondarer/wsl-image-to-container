#!/bin/bash

# rootless podman-compose では、正しく UID のマッピングができない (userns が利用できない) ため、
# podman を直接起動する

# 既存のコンテナを停止・削除
podman stop oracle_linux_8_1 1>/dev/null 2>/dev/null || true
podman rm oracle_linux_8_1 1>/dev/null 2>/dev/null || true

echo "Container stopped successfully."
