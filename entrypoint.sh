#!/bin/bash
set -e

# AozoraEpub3ディレクトリが空の場合は初期化
if [ -z "$(ls -A /app/aozoraepub3)" ]; then
    echo "Initializing AozoraEpub3 directory..."
    # 初期データを一時ディレクトリから復元
    if [ -d "/tmp/aozoraepub3_initial" ]; then
        cp -R /tmp/aozoraepub3_initial/* /app/aozoraepub3/
    fi
    
    # Narou.rbの再初期化
    narou init -p /app/aozoraepub3
    narou setting server-ws-add-accepted-domains="*"
fi

# 実行コマンドを実行
exec "$@"