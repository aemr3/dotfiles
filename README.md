# dotfiles

This repository contains my dotfiles.

## Requirements

`git`, `curl`, `ps`, `gcc` is required to install the dotfiles. They are usually pre-installed on macOS with command line tools.
If you are using Linux, you can install them with the following commands:

```bash
sudo apt install git curl procps build-essential
```

## Installation

Clone the repository and run `install.sh` script. Or you can run the following command:

```bash
curl -sSL https://raw.githubusercontent.com/aemr3/dotfiles/main/install.sh | bash
```

It will install brew, zsh, oh-my-zsh, tmux, neovim, and other tools
and create symlinks in your home directory to the files in this repository.
