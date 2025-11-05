FROM node:18-slim

# 安裝 ripgrep、git 和 sudo
RUN apt-get update && apt-get install -y ripgrep git sudo && apt-get clean

# 安裝 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# 建立 user 帳號
RUN useradd -m -s /bin/bash user

# 將 user 加入 sudo 群組（免密碼）
RUN usermod -aG sudo user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 建立工作目錄並設定權限
WORKDIR /workspace
RUN chown user:user /workspace

# 切換到 user 帳號
USER user

# 預設啟動 claude，退出後進入 bash
CMD ["bash", "-c", "claude --dangerously-skip-permissions; exec bash"]
