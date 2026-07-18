#!/usr/bin/env bash
# 01-preflight.sh — OS check, Xcode CLT, Rosetta, Homebrew.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if ! is_macos; then
  warn "Not macOS — skipping preflight (Xcode CLT / Rosetta / Homebrew)."
  exit 0
fi

# ── Xcode Command Line Tools ──────────────────────────────────────────────
if ! xcode-select -p &>/dev/null; then
  log "Installing Xcode Command Line Tools …"
  xcode-select --install
  log "Waiting for Xcode CLT installation to complete …"
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  success "Xcode CLT installed."
else
  success "Xcode CLT already installed."
fi

# ── Rosetta 2 (Apple Silicon only) ────────────────────────────────────────
if is_arm; then
  if ! /usr/bin/pgrep -q oahd 2>/dev/null; then
    log "Installing Rosetta 2 …"
    softwareupdate --install-rosetta --agree-to-license
    success "Rosetta 2 installed."
  else
    success "Rosetta 2 already installed."
  fi
fi

# ── Homebrew ──────────────────────────────────────────────────────────────
if command_exists brew; then
  success "Homebrew already installed."
else
  log "Installing Homebrew …"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Determine brew prefix and wire into current shell + persistent shell config.
if is_arm; then
  BREW_PREFIX="/opt/homebrew"
else
  BREW_PREFIX="/usr/local"
fi

BREW_SHELLENV="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
append_once "$BREW_SHELLENV" "${HOME}/.zprofile"

# Activate brew in this script's session so subsequent scripts can use it.
eval "$("${BREW_PREFIX}/bin/brew" shellenv)"

success "Homebrew ready (prefix: ${BREW_PREFIX})."
