#!/usr/bin/env bash
# 04-macos-defaults.sh — sensible macOS system defaults.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

is_macos || { warn "Not macOS — skipping defaults."; exit 0; }

# Safari's defaults below need this terminal app to have Full Disk Access
# (System Settings > Privacy & Security > Full Disk Access), unrelated to
# whether Safari itself is running. Ask upfront instead of surprising the
# user with a raw "Could not write domain ...; exiting" mid-run.
fancy_echo "Note: Safari's defaults need this terminal app to have Full Disk Access (System Settings > Privacy & Security > Full Disk Access). Everything else below works without it."
read -rp "[sebx] Attempt Safari's defaults too? [Y/n] " SAFARI_REPLY
SKIP_SAFARI=false
[[ "$SAFARI_REPLY" =~ ^[Nn] ]] && SKIP_SAFARI=true

log "Writing macOS defaults …"

# ── Keyboard ─────────────────────────────────────────────────────────────
# Faster key repeat (lower is faster; default 6)
defaults write NSGlobalDomain KeyRepeat -int 2
# Shorter delay before key repeat kicks in (default 25)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Use F1-F12 as media/feature keys (volume, brightness, etc.) by default;
# hold fn for standard F1-F12 behavior
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool false
# Disable press-and-hold accent picker in favor of key repeat (useful for vim)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Caps Lock -> Control. `defaults write` can't do this reliably; the legacy
# mechanism is keyed per physical keyboard device ID, not portable across
# machines. hidutil remaps hardware-agnostically for every connected
# keyboard, but doesn't persist across reboots on its own, so a LaunchAgent
# reapplies it on every login.
CAPSLOCK_MAPPING='{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'
CAPSLOCK_AGENT="${HOME}/Library/LaunchAgents/com.sebx.capslock-remap.plist"

hidutil property --set "$CAPSLOCK_MAPPING" >/dev/null

mkdir -p "$(dirname "$CAPSLOCK_AGENT")"
cat > "$CAPSLOCK_AGENT" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.sebx.capslock-remap</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>${CAPSLOCK_MAPPING}</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)" "$CAPSLOCK_AGENT" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$CAPSLOCK_AGENT"

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
# New Finder windows open in the home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"
# Search the current folder by default (instead of "This Mac")
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# ── Dock ──────────────────────────────────────────────────────────────────
defaults write com.apple.dock orientation -string "left"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
# Enable magnification on hover
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock largesize -int 64
# Genie minimize effect
defaults write com.apple.dock mineffect -string "genie"

# ── Trackpad / Mouse ─────────────────────────────────────────────────────
# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Enable three-finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# ── Menu bar ─────────────────────────────────────────────────────────────
# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
# Show date + time with seconds in the clock
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm:ss a"
# Note: on Ventura+ some menu bar/Control Center toggles above may need a
# manual flip in System Settings > Control Center; `defaults write` no
# longer reliably drives every item after the Control Center rework.

# ── Safari ────────────────────────────────────────────────────────────────
if [[ "$SKIP_SAFARI" == true ]]; then
  warn "Skipping Safari's defaults by request. Grant Full Disk Access and re-run ./install.sh defaults to apply them later."
else
  # Still handled gracefully in case Full Disk Access wasn't actually granted.
  set +e
  SAFARI_FAILED=0
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true || SAFARI_FAILED=1  # full URL in address bar
  defaults write com.apple.Safari IncludeDevelopMenu -bool true || SAFARI_FAILED=1             # Develop menu
  defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true || SAFARI_FAILED=1
  set -e

  if [[ $SAFARI_FAILED -eq 1 ]]; then
    warn "Couldn't write Safari's defaults (needs Full Disk Access). Grant it to your terminal app in System Settings > Privacy & Security > Full Disk Access, then re-run ./install.sh defaults."
  fi
fi

# ── Apply ─────────────────────────────────────────────────────────────────
killall Dock Finder SystemUIServer 2>/dev/null || true

success "macOS defaults applied."
fancy_echo "Note: Some changes require a logout/reboot to fully take effect."
