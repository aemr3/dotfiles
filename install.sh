#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

. scripts/env.sh
. scripts/config.sh
. scripts/apps.sh
. scripts/utils.sh

check_essential_packages
install_brew
install_ohmyzsh
enable_zsh
install_brew_packages
configure_sudo_touchid
configure_dock
configure_finder
configure_trackpad
configure_keyboard
stow_dotfiles
install_agent_harnesses

success "Installation complete."
success "Please restart your terminal to apply changes."
success "You can run 'brew bundle' to install your apps."
