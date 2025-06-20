#!/usr/bin/env bash

# 將當前目錄名稱作為 container 名稱，例如在 ./myproject -> claude-myproject
BASENAME=$(basename "$PWD")
NAME="claude-${BASENAME}"
IMAGE=claude-code-cli

# 統一把 .claude 憑證掛在家目錄
CLAUDE_CONF="$HOME/.claude"

# 判斷 container 是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Container '${NAME}' already exists. Attaching..."
  docker start -ai "$NAME"
else
  echo "Container '${NAME}' not found. Creating and running..."
  docker run -it --name "$NAME" \
    -v "$CLAUDE_CONF:/root/.claude" \
    -v "$PWD:/workspace" \
    -w /workspace \
    "$IMAGE"
fi

