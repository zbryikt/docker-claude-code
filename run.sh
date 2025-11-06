#!/usr/bin/env bash

set -e

# 預設參數
PROFILE="default"
RESET=0
CLI="claude"  # 預設使用 claude

# 解析參數
while [[ $# -gt 0 ]]; do
  case $1 in
    --reset)
      RESET=1
      shift
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --cli)
      CLI="$2"
      shift 2
      ;;
    *)
      echo "未知參數: $1"
      echo "用法: $0 [--profile PROFILE] [--cli claude|gemini] [--reset]"
      exit 1
      ;;
  esac
done

# 驗證 CLI 參數
if [[ "$CLI" != "claude" && "$CLI" != "gemini" ]]; then
  echo "錯誤: --cli 只能是 'claude' 或 'gemini'"
  exit 1
fi

# 產生 container 名稱，使用 llmcli 開頭（通用，不綁定特定 CLI）
BASENAME=$(echo "$PWD" | md5sum | cut -d' ' -f1 | cut -c1-16)
NAME="llmcli-${BASENAME}-${PROFILE}"
IMAGE=llmcli

# 配置目錄結構：所有 CLI 的配置都存在同一個 profile 下
PROFILE_DIR="$HOME/.llmcli/profiles/${PROFILE}"
mkdir -p "$PROFILE_DIR"

# 移除舊 container（如果指定了 --reset）
if [[ $RESET -eq 1 ]]; then
  echo "Resetting container '${NAME}'..."
  docker rm -f "$NAME" 2>/dev/null || true
fi

# 根據選擇的 CLI 設定啟動命令
if [[ "$CLI" == "claude" ]]; then
  CLI_CMD="claude --dangerously-skip-permissions"
elif [[ "$CLI" == "gemini" ]]; then
  CLI_CMD="gemini --yolo"
fi

# 判斷 container 是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Container '${NAME}' already exists. Attaching..."
  echo "Starting with ${CLI}..."
  docker start -ai "$NAME"
else
  echo "Creating new container '${NAME}'..."
  echo "Will start with ${CLI}..."
  docker run -it --name "$NAME" \
    -v "$PROFILE_DIR:/home/user" \
    -v "$PROFILE_DIR:/root" \
    -v "$PWD:/workspace" \
    -w /workspace \
    -e CLI_NAME="$CLI" \
    -e CLI_CMD="$CLI_CMD" \
    "$IMAGE"
fi

