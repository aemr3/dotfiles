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
  if ! brew list --formula | grep -q tmux; then
    info "Installing latest tmux..."
    brew install tmux --HEAD
  fi
  initial_packages="neovim gh glab stow"
  missing_packages=""
  for package in $initial_packages; do
    if ! brew list --formula | grep -q $package; then
      missing_packages="$missing_packages $package"
    fi
  done
  if [ -n "$missing_packages" ]; then
    info "Installing brew packages..."
    brew install $missing_packages
  fi
}
