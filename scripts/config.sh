#!/usr/bin/env bash

enable_zsh() {
  if [ "$OS" == "linux" ]; then
    if [ "$SHELL" != "zsh" ]; then
      info "Setting zsh as default shell..."
      # Check if zsh is installed
      if ! command -v zsh &>/dev/null; then
        brew install zsh
      fi
      sudo chsh -s $(which zsh) $USER
    fi
  fi
}

stow_dotfiles() {
  if [ ! -d "$HOME/.config" ]; then
    mkdir -p $HOME/.config
  fi

  local to_stow="$(find stow -maxdepth 1 -type d -mindepth 1 | awk -F "/" '{print $NF}' ORS=' ')"
  info "Stowing: $to_stow"
  for dir in $to_stow; do
    stow -d stow -v -t "$HOME" --no-folding --adopt "$dir"
  done
}
