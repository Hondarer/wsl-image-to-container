#!/bin/bash

# /home/user が空の場合に初期ファイルを配置
if [ -z "$(ls -A /home/user)" ]; then
    echo "Initializing home..."

    cd /tmp
    rm -rf user
    mkdir user
    cd user
    cp -a /etc/skel/. .

    echo export LANG=ja_JP.UTF-8 >> .bashrc

    echo 'export PATH="$HOME/.node_modules/bin:$PATH"' >> .bashrc
    echo "prefix=/home/user/.node_modules" >> .npmrc
    mkdir -p .node_modules/bin

    cd /tmp
    chown -R user:user user
    chmod 700 user

    cp -rp /tmp/user/. /home/user/.
fi

# ssh を待ち受け (ここでブロックされる)
echo "Starting sshd..."
sudo /usr/sbin/sshd -D
