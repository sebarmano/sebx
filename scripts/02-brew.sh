#!/usr/bin/env bash
# 02-brew.sh — install / update packages from Brewfile.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if ! is_macos; then
  warn "Not macOS — skipping Homebrew bundle."
  exit 0
fi

if ! command_exists brew; then
  err "Homebrew not found. Run 01-preflight.sh first."
  exit 1
fi

log "Updating Homebrew …"
brew update

log "Installing from Brewfile …"
brew bundle --file="${REPO}/Brewfile"

success "Brew bundle complete."
