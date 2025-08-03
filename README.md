# wsl-image-to-container

## イメージのビルド

```bash
podman build -t oracle_linux:8 ./src/oracle_linux_8/
```

成果物は、`~/.local/share/containers/` に配置される。

## 基本的な動作確認

### コンテナを起動して動作確認

```bash
podman run -it --rm oracle_linux:8 /bin/bash
```

### Oracle Linux のバージョン確認

```bash
cat /etc/oracle-release
```

### dnf が正常に動作するか確認

```bash
dnf --version
```

## コンテナイメージのセーブ

エクスポートとセーブは意味が異なるので注意する。

| 項目           | podman save            | podman export          |
|----------------|------------------------|------------------------|
| 対象           | イメージ               | コンテナ               |
| レイヤー       | 保持される             | 単一レイヤーに統合     |
| メタデータ     | 保持される             | 失われる               |
| 履歴           | 保持される             | 失われる               |
| ファイルサイズ | 大きい                 | 小さい                 |
| 用途           | イメージの配布         | ファイルシステムの移行 |

podman save oracle_linux:8 | gzip -9 > oracle_linux_8.tar.gz

## コンテナイメージのインポート

gzip -dc oracle_linux_8.tar.gz | podman load
