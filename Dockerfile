FROM node:18-slim

# 安裝 ripgrep、git、sudo 和 pyenv 所需的依賴
RUN apt-get update && apt-get install -y \
    procps \
    ripgrep \
    git \
    sudo \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    && apt-get clean

# 安裝 Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code @google/gemini-cli

# 建立 user 帳號
RUN useradd -m -s /bin/bash user

# 將 user 加入 sudo 群組（免密碼）
RUN usermod -aG sudo user && echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 建立工作目錄並設定權限
WORKDIR /workspace
RUN chown user:user /workspace

# 切換到 user 帳號
USER user

# 安裝 pyenv
RUN curl https://pyenv.run | bash

# 設定 pyenv 環境變數
ENV PYENV_ROOT="/home/user/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"

# 安裝 Python 3.11 並設為全局版本
RUN eval "$(pyenv init -)" && \
    pyenv install 3.11 && \
    pyenv global 3.11

# 將 pyenv 初始化加入 .bashrc
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc

# 複製並設定啟動腳本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 使用啟動腳本
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
