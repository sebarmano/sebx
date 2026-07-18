#!/usr/bin/env bash
# 04-macos-defaults.sh — sensible macOS system defaults.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

is_macos || { warn "Not macOS — skipping defaults."; exit 0; }

log "Writing macOS defaults …"

# ── Keyboard ─────────────────────────────────────────────────────────────
# Faster key repeat (lower is faster; default 6)
defaults write NSGlobalDomain KeyRepeat -int 2
# Shorter delay before key repeat kicks in (default 25)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# ── Screenshots ───────────────────────────────────────────────────────────
mkdir -p "${HOME}/Screenshots"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# ── Finder ────────────────────────────────────────────────────────────────
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show status bar and path bar
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder ShowPathbar -bool true
# Avoid .DS_Store on network / USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# ── Dock ──────────────────────────────────────────────────────────────────
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false

# ── Trackpad / Mouse ─────────────────────────────────────────────────────
# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ── Apply ─────────────────────────────────────────────────────────────────
killall Dock Finder SystemUIServer 2>/dev/null || true

success "macOS defaults applied."
fancy_echo "Note: Some changes require a logout/reboot to fully take effect."
