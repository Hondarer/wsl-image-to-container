# RHEL (Oracle Linux) 起動時に rootless でコンテナを自動起動する systemd セットアップ

このチュートリアルでは、RHEL (Oracle Linux) 起動時にユーザー権限で systemd を使用して rootless podman コンテナを自動的に起動する方法を説明します。

## 前提条件

- RHEL (Oracle Linux) 環境
- rootless podman がセットアップ済み
- プロジェクトディレクトリ: `/home/user/wsl-image-to-container` (適宜変更)
- ユーザー名: `user` (適宜変更)

## セットアップ手順

### systemd ユーザーサービスディレクトリの作成

```bash
mkdir -p ~/.config/systemd/user
```

### systemd サービスファイルの作成

`~/.config/systemd/user/wsl-container.service` を作成します。

```bash:~/.config/systemd/user/wsl-container.service
cat > ~/.config/systemd/user/wsl-container.service << 'EOF'
[Unit]
Description=WSL Container Auto Start Service
After=network.target
Wants=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/user/wsl-image-to-container
ExecStart=/home/user/wsl-image-to-container/start-pod.sh
ExecStop=/home/user/wsl-image-to-container/stop-pod.sh
Environment="HOME=/home/user"
Environment="XDG_RUNTIME_DIR=/run/user/1000"

[Install]
WantedBy=default.target
EOF
```

**注意**: `/home/user` 部分は実際のユーザー名に置き換えてください。

### systemd ユーザーサービスのリロードと有効化

```bash
# systemctl daemon をリロード
systemctl --user daemon-reload

# サービスを有効化 (自動起動設定)
systemctl --user enable wsl-container.service

# (podman.socket は不要 - user@1000.service が自動的に管理)

# ユーザーの lingering を有効化 (ユーザーがログアウトしてもサービスが継続実行される)
sudo loginctl enable-linger user
```

### サービスの動作確認

#### 手動でサービスを開始してテスト

```bash
systemctl --user start wsl-container.service
```

#### サービスの状態確認

```bash
systemctl --user status wsl-container.service
```

#### コンテナが起動しているか確認

```bash
podman ps
```

#### サービスログの確認

```bash
journalctl --user -u wsl-container.service -f
```

### システム再起動でのテスト

```bash
sudo reboot
```

再起動後、以下のコマンドでコンテナが自動的に起動されているか確認します。

```bash
podman ps
systemctl --user status wsl-container.service
```

## 設定のカスタマイズ

### サービス名の変更

サービス名を変更したい場合は、ファイル名を変更します。

```bash
mv ~/.config/systemd/user/wsl-container.service ~/.config/systemd/user/your-service-name.service
```

### 異なるプロジェクトディレクトリの場合

`WorkingDirectory` と `ExecStart`、`ExecStop` のパスを適切に変更してください。

```ini
WorkingDirectory=/path/to/your/project
ExecStart=/path/to/your/project/start-pod.sh
ExecStop=/path/to/your/project/stop-pod.sh
```

### 環境変数の追加

必要に応じて `Environment` セクションに追加の環境変数を設定できます。

```ini
Environment="CUSTOM_VAR=value"
Environment="ANOTHER_VAR=another_value"
```

## サービス管理コマンド

### サービス制御

```bash
# サービス開始
systemctl --user start wsl-container.service

# サービス停止
systemctl --user stop wsl-container.service

# サービス再起動
systemctl --user restart wsl-container.service

# 自動起動の無効化
systemctl --user disable wsl-container.service

# 自動起動の有効化
systemctl --user enable wsl-container.service
```

### 状態確認

```bash
# サービス状態確認
systemctl --user status wsl-container.service

# 有効なユーザーサービス一覧
systemctl --user list-unit-files --state=enabled

# ログ確認（リアルタイム）
journalctl --user -u wsl-container.service -f

# 最近のログ確認
journalctl --user -u wsl-container.service --since "1 hour ago"
```

## トラブルシューティング

### サービスが起動しない場合

1. **権限の確認**
   ```bash
   # スクリプトが実行可能か確認
   ls -la /home/user/wsl-image-to-container/start-pod.sh
   
   # 実行権限が無い場合は追加
   chmod +x /home/user/wsl-image-to-container/start-pod.sh
   ```

2. **パスの確認**
   ```bash
   # 実際のパスが正しいか確認
   ls -la /home/user/wsl-image-to-container/
   ```

3. **systemd ログの詳細確認**
   ```bash
   journalctl --user -u wsl-container.service --no-pager
   ```

### lingering が正しく設定されていない場合

```bash
# lingering の状態確認
loginctl show-user user | grep Linger

# lingering を有効化
sudo loginctl enable-linger user
```

### XDG_RUNTIME_DIR エラーの場合

ユーザー ID が 1000 以外の場合、適切なパスに変更してください。

```bash
# ユーザーIDを確認
id -u

# service ファイル内の XDG_RUNTIME_DIR を調整
Environment="XDG_RUNTIME_DIR=/run/user/$(id -u)"
```

## 参考情報

- [systemd.service マニュアル](https://www.freedesktop.org/software/systemd/man/systemd.service.html)
- [systemd/User マニュアル](https://wiki.archlinux.org/title/systemd/User)
- [Podman systemd integration](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)
