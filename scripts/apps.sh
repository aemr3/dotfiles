#!/usr/bin/env bash

check_essential_packages() {
  missing_packages=""
  for package in $ESSENTIAL_PACKAGES; do
    if ! command -v $package &>/dev/null; then
      missing_packages="$missing_packages $package"
    fi
  done
  if [ -n "$missing_packages" ]; then
    err "Error: Required packages \"$(sed -e 's/^[ \t]*//' <<<"${missing_packages}")\" not installed."
    err "Please install them and run this script again."
    exit 1
  fi
}

install_brew() {
  export PATH="$HOMEBREW_PATH/bin:$PATH"
  if ! command -v brew &>/dev/null; then
    info "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ $? -ne 0 ]; then
      err "Failed to install homebrew."
      exit 1
    fi
    eval "$($HOMEBREW_PATH/bin/brew shellenv)"
  fi
}

install_ohmyzsh() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    info "Installing oh-my-zsh..."
    git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
    git clone https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
  fi
}

install_brew_packages() {
  initial_packages="tmux neovim gh glab stow"
  missing_packages=""
  for package in $initial_packages; do
    if ! brew list --formula "$package" &>/dev/null; then
      missing_packages="$missing_packages $package"
    fi
  done
  if [ -n "$missing_packages" ]; then
    info "Installing brew packages..."
    brew install $missing_packages
  fi
}

install_agent_harnesses() {
  export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

  if ! command -v claude &>/dev/null; then
    info "Installing Claude Code..."
    curl -fsSL https://claude.ai/install.sh | bash
  fi

  if ! command -v codex &>/dev/null; then
    info "Installing Codex..."
    curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh
  fi

  if ! command -v opencode &>/dev/null; then
    info "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash -s -- --no-modify-path
  fi

  if ! command -v pi &>/dev/null; then
    if command -v node &>/dev/null; then
      info "Installing pi..."
      curl -fsSL https://pi.dev/install.sh | without_tty sh
    else
      warn "Skipping pi: it needs Node.js 22.19 or newer on PATH."
    fi
  fi

  if ! command -v agy &>/dev/null; then
    info "Installing Antigravity CLI..."
    local agy_home
    agy_home=$(mktemp -d)
    curl -fsSL https://antigravity.google/cli/install.sh | HOME="$agy_home" bash
    mkdir -p "$HOME/.local/bin"
    mv "$agy_home/.local/bin/agy" "$HOME/.local/bin/agy"
    rm -rf "$agy_home"
  fi
}
