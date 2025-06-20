FROM node:18-slim

# 安裝 ripgrep（選用，但 Claude 建議裝）
RUN apt-get update && apt-get install -y ripgrep && apt-get clean

# 安裝 Claude Code CLI（建議避免 sudo）
RUN npm install -g @anthropic-ai/claude-code

# 建立工作目錄（選擇你想放 project 的位置）
WORKDIR /workspace

# 預設啟動 shell
CMD ["bash"]
