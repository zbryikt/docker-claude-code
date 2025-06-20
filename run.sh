#!/usr/bin/env bash
docker run -it \
  --name claude-session \
  -v $HOME/.claude:/root/.claude \
  claude-code-cli
