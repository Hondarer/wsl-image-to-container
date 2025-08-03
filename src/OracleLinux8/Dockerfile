FROM scratch
EXPOSE 22

# Oracle Linux WSL の tar.gz ファイルを展開して root ファイルシステムとして追加
ADD OracleLinux8.tar.gz /

# user のホーム初期化スクリプトを追加
ADD entrypoint.sh /usr/local/bin
RUN chown root:root /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

# Oracle Linux 用の環境変数を設定
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV SHELL="/bin/bash"

# ロケール設定
ENV LANG=ja_JP.UTF-8

# 作業用ユーザーの SSH パスワードの設定
RUN echo 'user:user_passwd' | chpasswd

# SSH キー認証の有効化
RUN sed -i 's/^#\s*PubkeyAuthentication\s\+yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# ユーザーの切り替え
USER user

# 作業用ディレクトリの作成
WORKDIR /workspace

# コンテナ起動時に実行するスクリプト
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
