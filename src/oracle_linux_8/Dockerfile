FROM scratch
EXPOSE 22

# Oracle Linux WSL の tgz ファイルを展開して root ファイルシステムとして追加
ADD oracle-linux-8-wsl.tgz /

# user のホーム初期化スクリプトを追加
ADD entrypoint.sh /usr/local/bin
RUN chown root:root /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

# Oracle Linux 用の環境変数を設定
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ENV SHELL="/bin/bash"

# ロケール設定
ENV LANG=ja_JP.UTF-8

# 作業用ユーザーのパスワードの設定
# SSH には、パスワードが必要
RUN echo 'user:user_passwd' | chpasswd

# ユーザーの切り替え
USER user

# 作業用ディレクトリの作成
WORKDIR /workspace

# コンテナ起動時に実行するスクリプト
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
