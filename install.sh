#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/aemr3/dotfiles.git"
USER=${USER:-$(id -u -n)}
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"
HOME="${HOME:-$(eval echo ~$USER)}"
SHELL=$(getent passwd $USER 2>/dev/null | cut -d : -f 7 | xargs basename)
ESSENTIAL_PACKAGES="git curl ps gcc"
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# Define colors
RED=""
GREEN=""
NC=""
if [ -t 1 ]; then
  ncolors=$(tput colors)
  if [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    NC='\033[0m'
  fi
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  HOMEBREW_PATH="/opt/homebrew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
else
  echo -e "${RED}Unsupported operating system.${NC}"
  exit 1
fi

# Check if essential packages are installed
missing_packages=""
for package in $ESSENTIAL_PACKAGES; do
  if ! command -v $package &>/dev/null; then
    missing_packages="$missing_packages $package"
  fi
done
if [ -n "$missing_packages" ]; then
  echo -e "${RED}Error: Required packages \"$(sed -e 's/^[ \t]*//' <<<"${missing_packages}")\" not installed.${NC}"
  echo -e "${RED}Please install them and run this script again.${NC}"
  exit 1
fi

# Check if we are in the dotfiles git repository
# If not, clone the repository to $HOME/.dotfiles and cd into it
if [ ! -d "$SCRIPT_DIR/.git" ]; then
  if [ -d "$HOME/.dotfiles" ]; then
    echo -e "${GREEN}Updating dotfiles repository...${NC}"
    cd $HOME/.dotfiles
    git pull
  else
    echo -e "${GREEN}Cloning dotfiles repository...${NC}"
    git clone $REPO_URL $HOME/.dotfiles
    cd $HOME/.dotfiles
  fi
else
  cd $SCRIPT_DIR
  git pull 2>/dev/null >/dev/null
fi

# Install homebrew
export PATH="$HOMEBREW_PATH/bin:$PATH"
if ! command -v brew &>/dev/null; then
  echo -e "${GREEN}Installing homebrew...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to install homebrew.${NC}"
    exit 1
  fi
  eval "$($HOMEBREW_PATH/bin/brew shellenv)"
fi

# Enable zsh as default shell on linux
if [ "$OS" == "linux" ]; then
  if [ "$SHELL" != "zsh" ]; then
    echo -e "${GREEN}Setting zsh as default shell...${NC}"
    # Check if zsh is installed
    if ! command -v zsh &>/dev/null; then
      brew install zsh
    fi
    sudo chsh -s $(which zsh) $USER
  fi
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo -e "${GREEN}Installing oh-my-zsh...${NC}"
  git clone https://github.com/ohmyzsh/ohmyzsh.git $HOME/.oh-my-zsh
  git clone https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k
  git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

# Install nerd-fonts on macos
if [ "$OS" == "macos" ]; then
  INSTALLED_CASKS=$(brew list --cask | grep 'font-.*-nerd-font' | wc -l)
  TOTAL_CASKS=$(brew search --cask '/font-.*-nerd-font/' | wc -l)
  if [ $INSTALLED_CASKS -lt $TOTAL_CASKS ]; then
    echo -e "${GREEN}Installing nerd-fonts...${NC}"
    brew search --cask '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {}
  fi
fi

# Install brew packages
initial_packages="tmux neovim gh glab stow"
missing_packages=""
for package in $initial_packages; do
  if ! brew list --formula | grep -q $package; then
    missing_packages="$missing_packages $package"
  fi
done
if [ -n "$missing_packages" ]; then
  echo -e "${GREEN}Installing brew packages...${NC}"
  brew install $missing_packages
fi

# Install dotfiles
echo -e "${GREEN}Installing dotfiles...${NC}"
stow -t $HOME -v --adopt -R . --ignore=install.sh
echo -e "${GREEN}Dotfiles installed successfully.${NC}"
echo -e "${GREEN}Please restart your terminal to apply changes.${NC}"
echo -e "${GREEN}You can run 'brew bundle' to install your apps.${NC}"
