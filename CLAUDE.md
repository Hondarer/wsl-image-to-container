# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 主要コマンド

### コンテナイメージのビルド

```bash
./build-pod.sh
```
- OracleLinux8.tar.gz ファイルが存在することを確認してからビルドを実行
- 既存のコンテナを停止し、旧イメージを削除してから新しいイメージをビルド

### コンテナの起動

```bash
./start-pod.sh
```
- イメージが存在しない場合は自動的にビルドを実行
- --userns=keep-id を使用して UID/GID マッピングを保持
- SSH 接続用にポート 40022 でアクセス可能

### コンテナの停止・削除

```bash
./stop-pod.sh
```

## 基本的な動作確認

### コンテナを起動して動作確認

```bash
podman run -it --rm --user $(whoami) {コンテナ名} /bin/bash
```

### (コンテナ内で) Oracle Linux のバージョン確認

```bash
cat /etc/oracle-release
```

### (コンテナ内で) 生成されたコンテナのバージョン確認

```bash
cat /etc/container-release
```

### (コンテナ内で) dnf が正常に動作するか確認

```bash
dnf --version
```

## アーキテクチャ

### プロジェクト構造

- `src/`: Oracle Linux 8 の Dockerfile とファイル群
  - `Dockerfile`: scratch ベースで Oracle Linux WSL イメージを展開
  - `OracleLinux8.tar.gz`: Oracle Linux WSL の root ファイルシステム
  - `entrypoint.sh`: 初回起動時のホームディレクトリ初期化と SSH サーバ起動
- `storage/1/`: コンテナのマウントポイント用ディレクトリ
  - `home_{ユーザー名}/`: ユーザーホームディレクトリ
  - `workspace/`: 作業用ディレクトリ

### コンテナ設計

- scratch ベースイメージから Oracle Linux WSL ファイルシステムを展開
- rootless podman で UID/GID マッピングを保持 (--userns=keep-id)
- SSH 接続を前提とした設計 (ポート 22 をホストの 40022 にマッピング)
- 鍵認証で SSH 接続可能 (鍵がない場合、パスワード: {ユーザー名}_passwd でパスワード認証可能)
- 日本語ロケール (ja_JP.UTF-8) 設定済

### エントリーポイント処理

- ホームディレクトリが空の場合、skel ファイルを配置
- Node.js 用の環境変数とパス設定を自動追加
- SSH デーモンをフォアグラウンドで起動

## 開発時の注意点

### 必要ファイル

- `src/OracleLinux8.tar.gz` が必須
- このファイルが存在しない場合、ビルドスクリプトは警告を出して終了

### ボリュームマウント

- SELinux 環境での適切な権限設定のため :Z フラグを使用
- ホストとコンテナの UID/GID マッピングに依存する設計

## TODO or IDEA
