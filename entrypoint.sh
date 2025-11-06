#!/bin/bash

# 從環境變數取得 CLI 設定
CLI_CMD=${CLI_CMD:-"claude --dangerously-skip-permissions"}
CLI_NAME=${CLI_NAME:-"claude"}

# 顯示歡迎訊息
echo "=========================================="
echo "LLM CLI Container"
echo "Current CLI: ${CLI_NAME}"
echo "=========================================="
echo ""
echo "可用的 CLI 命令："
echo "  - claude"
echo "  - gemini"
echo ""
echo "啟動 ${CLI_NAME}..."
echo ""

# 執行指定的 CLI，退出後進入 bash
eval "$CLI_CMD" || true

# 確保回到一個存在的目錄
cd /workspace 2>/dev/null || cd ~ 2>/dev/null || cd /

exec bash
