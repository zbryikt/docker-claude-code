#!/usr/bin/env bash

set -e

# 預設參數
PROFILE="default"
RESET=0

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
    *)
      echo "未知參數: $1"
      exit 1
      ;;
  esac
done

# 產生 container 名稱，使用路徑哈希避免同名目錄衝突
BASENAME=$(echo "$PWD" | md5sum | cut -d' ' -f1 | cut -c1-16)
NAME="claude-${BASENAME}-${PROFILE}"
IMAGE=claude-code-cli

# Claude Code session 掛載路徑
USER_HOME="$HOME/.claude-code/profiles/${PROFILE}"
mkdir -p "$USER_HOME"

# 移除舊 container（如果指定了 --reset）
if [[ $RESET -eq 1 ]]; then
  echo "Resetting container '${NAME}'..."
  docker rm -f "$NAME" 2>/dev/null || true
fi

# 判斷 container 是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Container '${NAME}' already exists. Attaching..."
  docker start -ai "$NAME"
else
  echo "Creating new container '${NAME}'..."
  docker run -it --name "$NAME" \
    -v "$USER_HOME:/home/user" \
    -v "$USER_HOME:/root" \
    -v "$PWD:/workspace" \
    -w /workspace \
    "$IMAGE"
fi

