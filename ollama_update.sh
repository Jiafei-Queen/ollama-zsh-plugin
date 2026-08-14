#!/bin/sh
# ollama-zsh-plugin: 辅助脚本 —— "ollama update"
# 1. 从 GitHub tags 页面提取最新稳定版本号（排除 rc 版本），与本地版本对比并请求确认
# 2. 询问是否停止 ollama serve 进程（不论是或否都继续）
# 3. 执行官方安装脚本：curl -fsSL https://ollama.com/install.sh | sh

# 获取最新稳定版本号（tags 页面按时间倒序，过滤掉 rc 版本后第一个即为最新稳定版）
latest=$(curl -fsSL https://github.com/ollama/ollama/tags 2>/dev/null \
  | grep -oE 'releases/tag/v[0-9]+\.[0-9]+\.[0-9]+(-rc[0-9]+)?' \
  | sed 's|releases/tag/||' \
  | grep -vE -e '-rc[0-9]+$' \
  | head -n 1)

if [ -z "$latest" ]; then
  echo "ollama-plugin: Failed to fetch the latest version, abort update."
  exit 1
fi

# 本地版本（"ollama --version" 输出形如 "ollama version is 0.32.9"）
local_version=$(command ollama --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

if [ -n "$local_version" ] && [ "$local_version" = "${latest#v}" ]; then
  echo "ollama-plugin: Already up to date (v$local_version), no need to install."
  exit 0
fi

# 请求确认安装此版本
if [ -n "$local_version" ]; then
  printf "ollama-plugin: Latest stable version is %s (local version: %s). Install it? [y/N] " "$latest" "$local_version"
else
  printf "ollama-plugin: Latest stable version is %s (local version not detected). Install it? [y/N] " "$latest"
fi
read -r answer
case "$answer" in
  y|Y|yes|YES) ;;
  *)
    echo "ollama-plugin: Install cancelled."
    exit 0
    ;;
esac

# 询问是否停止 ollama serve（不论是或否都继续脚本）
printf "ollama-plugin: Stop the ollama serve process before installing? [y/N] "
read -r answer
case "$answer" in
  y|Y|yes|YES)
    pkill -f "ollama serve" 2>/dev/null || true
    echo "ollama-plugin: ollama serve stopped."
    ;;
  *)
    echo "ollama-plugin: Keep ollama serve running."
    ;;
esac

# 执行官方安装脚本
curl -fsSL https://ollama.com/install.sh | sh
