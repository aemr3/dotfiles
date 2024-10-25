#!/usr/bin/env bash

set -o errexit
set -o nounset

. scripts/env.sh
. scripts/config.sh
. scripts/apps.sh
. scripts/fonts.sh
. scripts/utils.sh

check_essential_packages
install_brew
install_ohmyzsh
enable_zsh
install_nerd_fonts
install_brew_packages
stow_dotfiles

success "Installation complete."
success "Please restart your terminal to apply changes."
success "You can run 'brew bundle' to install your apps."
