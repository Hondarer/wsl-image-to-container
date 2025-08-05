FROM scratch
EXPOSE 22

# ビルド引数の定義
ARG USER_NAME=user
ARG UID=1000
ARG GID=1000

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

# デフォルトユーザー (user 1000:1000) の削除とユーザー作成
# ※ベースイメージに user が存在することが前提
RUN (userdel -r user || true) && \
    groupadd -g ${GID} ${USER_NAME} && \
    useradd -u ${UID} -g ${GID} -G wheel -d /home/${USER_NAME} -m -s /bin/bash ${USER_NAME} && \
    echo ${USER_NAME}:${USER_NAME}_passwd | chpasswd

# ユーザーの切り替え
USER ${USER_NAME}

# 作業用ディレクトリの作成
WORKDIR /workspace

# コンテナ起動時に実行するスクリプト
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
