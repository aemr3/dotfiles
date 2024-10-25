#!/usr/bin/env bash

. scripts/utils.sh

REPO_URL="https://github.com/aemr3/dotfiles.git"
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"
SHELL=$(getent passwd $USER 2>/dev/null | cut -d : -f 7 | xargs basename)
ESSENTIAL_PACKAGES="git curl ps gcc"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  HOMEBREW_PATH="/opt/homebrew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
else
  err "Unsupported operating system!"
  exit 1
fi
