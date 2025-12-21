# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Enable Homebrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
  export HOMEBREW_PATH="/opt/homebrew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  OS="linux"
  export HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
fi
export HOMEBREW_BUNDLE_FILE="$HOME/.config/brew/Brewfile"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
eval $($HOMEBREW_PATH/bin/brew shellenv)

# Activate oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git macos docker docker-compose kubectl ssh zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PATH/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PATH/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm"

# Load pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi

# Load goenv
if [[ -d "$HOME/.goenv" ]]; then
  eval "$(goenv init -)"
fi

# Load rbenv
if command -v rbenv &>/dev/null; then
  eval "$(rbenv init - --no-rehash zsh)"
fi

# Load cargo
if [[ -d "$HOME/.cargo" ]]; then
  source "$HOME/.cargo/env"
fi

# Install tmux tpm
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

# Pnpm setup
export PNPM_HOME=~/.pnpm
export PATH=$PATH:~/.pnpm

# Activate gcloud sdk
if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
  . "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
fi

# Aliases
alias vnc='function __vnc() { socat TCP-LISTEN:$1,reuseaddr EXEC:"ssh -p3422 root@$2 \"sudo socat STDIO UNIX-CONNECT:/run/vnc/$3.sock\""; unset -f __vnc; }; __vnc'
alias forward-local='function __forwardLocal() { ssh -N -L $1:127.0.0.1:$2 $3 `[ -n"$4" ] && echo $4`; unset -f __forwardLocal; }; __forwardLocal'
alias forward-remote='function __forwardRemote() { ssh -N -R $1:127.0.0.1:$2 $3 `[ -n"$4" ] && echo $4`; unset -f __forwardRemote; }; __forwardRemote'
alias k='kubectl'
alias kt='kubetail'
alias vim='nvim'
alias v='nvim'

# Functions
transfer() {
  if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
  tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile;
}
nsenter() {
  if [ $# -eq 0 ]; then echo -e "No arguments specified. Usage:\nnsenter <host-name> <namespace> <container-name>"; return 1; fi
  if [ $# -eq 1 ]; then
    set -- "$1" default nsenter
  fi
  kubectl run $3 --restart=Never -n $2 --rm -it --image overriden --overrides "{
    \"spec\": {
      \"hostPID\": true,
      \"hostNetwork\": true,
      \"nodeSelector\": { \"kubernetes.io/hostname\": \"$1\" },
      \"tolerations\": [{
          \"operator\": \"Exists\"
      }],
      \"containers\": [
        {
          \"name\": \"nsenter\",
          \"image\": \"alexeiled/nsenter\",
          \"command\": [
            \"/nsenter\", \"--all\", \"--target=1\", \"--\", \"su\", \"-\"
          ],
          \"stdin\": true,
          \"tty\": true,
          \"securityContext\": {
            \"privileged\": true
          },
          \"resources\": {
            \"requests\": {
              \"cpu\": \"10m\"
            }
          }
        }
      ]
    }
  }" --attach "$@"
}

# zsh history
unsetopt share_history
setopt inc_append_history
setopt no_share_history
setopt hist_find_no_dups
setopt hist_ignore_all_dups
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE

# Set defaults for macos
if [[ "$OS" == "macos" ]]; then
  defaults write -g ApplePressAndHoldEnabled -bool false
fi

# Custom exports
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR=nvim
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.bun/bin:$PATH
export PATH=${KREW_ROOT:-$HOME/.krew}/bin:$PATH
export PATH=$PATH:$HOME/.docker/bin
export GOBIN=$HOME/.local/bin
if [ -d ~/Library ]; then
  export PATH=$PATH:~/Library/Android/sdk/platform-tools
  export ANDROID_HOME=~/Library/Android/sdk
  export ANDROID_SDK_ROOT=~/Library/Android/sdk
fi
export OPENCODE_DISABLE_DEFAULT_PLUGINS=1
export NODE_OPTIONS="--experimental-sqlite"

# Key bindings
bindkey -e
bindkey '^[[1;3C' forward-word
bindkey '^[[1;3D' backward-word
