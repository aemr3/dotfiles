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

configure_dock() {
  if [ "$OS" != "macos" ]; then
    return 0
  fi

  info "Configuring Dock..."
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock tilesize -int 46
  defaults write com.apple.dock magnification -bool true
  defaults write com.apple.dock largesize -int 53
  defaults write com.apple.dock showAppExposeGestureEnabled -bool true

  local dock_apps=(
    "/System/Applications/Apps.app"
    "/Applications/Zen.app"
    "/Applications/Ghostty.app"
    "/Applications/Superset.app"
    "/Applications/Slack.app"
    "/Applications/Spark Desktop.app"
    "/Applications/TablePlus.app"
    "/Applications/WhatsApp.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Contacts.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Notes.app"
    "/System/Applications/App Store.app"
    "/System/Applications/iPhone Mirroring.app"
    "/System/Applications/Utilities/Activity Monitor.app"
    "/System/Applications/System Settings.app"
  )
  defaults write com.apple.dock persistent-apps -array
  for app in "${dock_apps[@]}"; do
    if [ ! -d "$app" ]; then
      warn "Skipping $(basename "$app" .app) in Dock: not installed yet."
      continue
    fi
    defaults write com.apple.dock persistent-apps -array-add \
      "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  done

  killall Dock
}

configure_finder() {
  if [ "$OS" != "macos" ]; then
    return 0
  fi

  info "Configuring Finder..."
  defaults write com.apple.finder NewWindowTarget -string "PfHm"
  defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
  defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
  defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
  defaults write com.apple.finder CreateDesktop -bool false
  defaults write com.apple.finder SidebarWidth2 -int 220
  killall Finder
}

configure_trackpad() {
  if [ "$OS" != "macos" ]; then
    return 0
  fi

  info "Configuring trackpad..."
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2
}

configure_keyboard() {
  if [ "$OS" != "macos" ]; then
    return 0
  fi

  info "Configuring keyboard..."
  defaults write com.apple.TextInputMenu visible -bool true
  defaults write com.apple.HIToolbox AppleFnUsageType -int 0
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

  local brightness="/var/root/Library/Preferences/com.apple.CoreBrightness.plist"
  sudo defaults write "$brightness" "Keyboard Dim Time" -int 300
  sudo defaults write "$brightness" KeyboardBacklight -dict-add KeyboardBacklightIdleDimTime -int 300
  sudo killall corebrightnessd 2>/dev/null || true
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
