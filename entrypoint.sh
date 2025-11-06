#!/bin/bash

# 取得要執行的 CLI 命令（從環境變數）
CLI_CMD=${CLI_CMD:-"claude --dangerously-skip-permissions"}

# 顯示歡迎訊息
echo "=========================================="
echo "LLM CLI Container"
echo "Current CLI: ${CLI_NAME:-claude}"
echo "=========================================="
echo ""
echo "可用的 CLI 命令："
echo "  - claude"
echo "  - gemini"
echo ""
echo "啟動 ${CLI_NAME:-claude}..."
echo ""

# 執行指定的 CLI，退出後進入 bash
eval "$CLI_CMD" || true
exec bash
