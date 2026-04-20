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

configure_sudo_touchid() {
  if [ "$OS" != "macos" ]; then
    return 0
  fi

  local pam_reattach="${HOMEBREW_PATH}/lib/pam/pam_reattach.so"
  local sudo_local="/etc/pam.d/sudo_local"

  if [ ! -f "$pam_reattach" ]; then
    info "Installing pam-reattach (needed for Touch ID sudo from tmux)..."
    brew install pam-reattach
  fi

  if [ -f "$sudo_local" ] \
    && grep -q "pam_tid.so" "$sudo_local" \
    && grep -q "pam_reattach.so" "$sudo_local"; then
    return 0
  fi

  info "Enabling Touch ID for sudo (allows sudo from tmux popups; falls back to password on SSH/VNC)..."
  sudo tee "$sudo_local" >/dev/null <<EOF
auth       optional     ${pam_reattach}
auth       sufficient   pam_tid.so
EOF
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
