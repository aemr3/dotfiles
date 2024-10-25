#!/usr/bin/env bash

install_nerd_fonts() {
  if [ "$OS" == "macos" ]; then
    INSTALLED_CASKS=$(brew list --cask | grep 'font-.*-nerd-font' | wc -l)
    TOTAL_CASKS=$(brew search --cask '/font-.*-nerd-font/' | wc -l)
    if [ $INSTALLED_CASKS -lt $TOTAL_CASKS ]; then
      echo -e "${GREEN}Installing nerd-fonts...${NC}"
      brew search --cask '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {}
    fi
  fi
}
