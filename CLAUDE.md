# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

root ファイルシステム (WSL からエクスポートしたイメージを想定) をコンテナイメージにして実行します。

## 主要コマンド

### コンテナイメージのビルド

```bash
./build-pod.sh
```
- src の下にある *.tar.gz または *.tgz ファイルを自動検出 (最新バージョンを使用)
- アーカイブファイル名からコンテナ名を自動生成 (CamelCase → snake_case 変換)
- container-release ファイルを自動生成してビルド情報を記録
- 既存のコンテナを停止し、旧イメージを削除してから新しいイメージをビルド
- ホストのユーザー情報 (USER_NAME, UID, GID) をビルド引数として渡す

### コンテナの起動

```bash
./start-pod.sh
```
- src 内のアーカイブファイルを自動検出してコンテナ名を決定
- イメージが存在しない場合は自動的にビルドを実行
- --userns=keep-id を使用して UID/GID マッピングを保持
- SSH 接続用にポート 40022 でアクセス可能
- --restart unless-stopped でコンテナの自動再起動を設定
- ~/.ssh/id_rsa.pub が存在する場合、authorized_keys に自動設定

### コンテナの停止・削除

```bash
./stop-pod.sh
```
- アーカイブファイル名から自動生成されたコンテナ名で停止・削除を実行

### systemd による自動起動

```bash
# チュートリアル参照
cat systemd-autostart-tutorial.md
```
- RHEL/Oracle Linux 起動時にユーザー権限で rootless podman コンテナを自動起動
- systemd user service として設定
- loginctl enable-linger でユーザーログアウト後も継続実行

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

- `src/`: Dockerfile とファイル群
  - `Dockerfile`: scratch ベースでアーカイブファイルを展開
  - `*.tar.gz` / `*.tgz`: root ファイルシステムアーカイブ (自動検出)
  - `entrypoint.sh`: 初回起動時のホームディレクトリ初期化と SSH サーバ起動
  - `container-release`: コンテナイメージ内に配置する /etc/container-release 情報 (build-pod.sh にて自動生成)
- `storage/1/`: コンテナのマウントポイント用ディレクトリ
  - `home_{ユーザー名}/`: ユーザーホームディレクトリの永続化
  - `workspace/`: 作業用ディレクトリの永続化
- `systemd-autostart-tutorial.md`: systemd 自動起動設定チュートリアル

### コンテナ設計

- scratch ベースイメージから root ファイルシステムを展開
- rootless podman で UID/GID マッピングを保持 (--userns=keep-id)
- SSH 接続を前提とした設計 (ポート 22 をホストの 40022 にマッピング)
- 鍵認証優先、フォールバック時パスワード認証: {ユーザー名}_passwd
- 日本語ロケール (ja_JP.UTF-8) 設定済
- wheel グループに所属して sudo 権限あり

### エントリーポイント処理

- ホームディレクトリが空の場合 (~/.ssh を除く)、/etc/skel から初期ファイルを配置
- Node.js 用の環境変数 (.bashrc) と npmrc 設定を自動追加
- authorized_keys が存在する場合、SSH 鍵認証を有効化してパスワード認証を無効化
- SSH デーモンをフォアグラウンドで起動 (-D フラグ)

## 開発時の注意点

### 必要ファイル

- `src/` 内に *.tar.gz または *.tgz ファイルが必須
- 複数存在する場合は最新バージョンを自動選択 (sort -V | tail -n 1)
- ファイルが存在しない場合、スクリプトは警告を出して終了

### アーカイブ命名とコンテナ名生成

- アーカイブファイル名例: `OracleLinux8.tar.gz` → コンテナ名: `oracle_linux8`
- CamelCase → snake_case 変換ルール適用
- 数字と文字の境界にもアンダースコアを挿入

### ボリュームマウント

- SELinux 環境での適切な権限設定のため :Z フラグを使用
- ホストとコンテナの UID/GID マッピングに依存する設計
- storage/1/ 以下でホームディレクトリとワークスペースを永続化

### SSH 接続

```bash
# 鍵認証 (推奨)
ssh -p 40022 user@localhost

# パスワード認証 (フォールバック)
# パスワード: user_passwd (ユーザー名 + "_passwd")
```

## systemd による運用

詳細は `systemd-autostart-tutorial.md` を参照：
- ユーザー systemd サービスとして登録
- OS 起動時の自動起動
- ログアウト後も継続実行 (linger)

## TODO or IDEA
