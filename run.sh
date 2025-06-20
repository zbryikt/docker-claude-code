#!/usr/bin/env bash

NAME=claude-session
IMAGE=claude-code-cli

if docker ps -a --format '{{.Names}}' | grep -q "^${NAME}$"; then
  echo "Container '${NAME}' already exists. Attaching..."
  docker start -ai "$NAME"
else
  echo "Container '${NAME}' not found. Creating and running..."
  docker run -it --name "$NAME" \
    -v "$HOME/.claude:/root/.claude" \
    -v "$PWD:/workspace" \
    "$IMAGE"
fi

