#!/usr/bin/env bash

set -e

# 預設參數
PROFILE="default"
RESET=0
CLI="claude"  # 預設使用 claude
PORTS=()  # 儲存端口映射

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
    -p|--port)
      PORTS+=("$2")
      shift 2
      ;;
    *)
      echo "未知參數: $1"
      echo "用法: $0 [--profile PROFILE] [--cli claude|gemini] [--reset] [-p|--port HOST:CONTAINER]"
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
  echo "Container '${NAME}' already exists."

  # 檢查是否指定了端口映射參數
  if [[ ${#PORTS[@]} -gt 0 ]]; then
    echo ""
    echo "WARNING: Port mapping (-p) specified but container already exists."
    echo "Port mappings can only be set when creating a new container."
    echo "To apply new port mappings, use: $0 --reset -p <ports>"
    echo ""
    read -p "Continue without applying port mappings? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi

  # 檢查容器中的 CLI_NAME 環境變數是否與當前選擇一致
  CONTAINER_CLI=$(docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' "$NAME" | grep "^CLI_NAME=" | cut -d'=' -f2)

  if [[ "$CONTAINER_CLI" != "$CLI" ]]; then
    echo "Detected CLI change: ${CONTAINER_CLI} -> ${CLI}"
    echo "Recreating container to apply new CLI setting..."
    docker rm -f "$NAME" 2>/dev/null || true
  else
    echo "Attaching to existing container with ${CLI}..."
    docker start -ai "$NAME"
    exit 0
  fi
fi

echo "Creating new container '${NAME}' with ${CLI}..."

# 構建端口映射參數
PORT_ARGS=()
for port in "${PORTS[@]}"; do
  PORT_ARGS+=("-p" "$port")
done

docker run -it --name "$NAME" \
  -v "$PROFILE_DIR:/home/user" \
  -v "$PROFILE_DIR:/root" \
  -v "$PWD:/workspace" \
  -w /workspace \
  -e CLI_NAME="$CLI" \
  -e CLI_CMD="$CLI_CMD" \
  "${PORT_ARGS[@]}" \
  "$IMAGE"

