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

log "Installing from Brewfile (Mac App Store apps need you already signed into App Store.app) …"
set +e
brew bundle --file="${REPO}/Brewfile"
BUNDLE_STATUS=$?
set -e

if [[ $BUNDLE_STATUS -eq 0 ]]; then
  success "Brew bundle complete."
  exit 0
fi

# Something didn't install — figure out whether it's just Mac App Store
# apps (likely not signed in) or a real failure.
UNMET="$(brew bundle check --file="${REPO}/Brewfile" --verbose 2>&1 || true)"
NON_APP_UNMET="$(grep '^→' <<< "$UNMET" | grep -v '^→ App ' || true)"
APP_UNMET="$(grep '^→ App ' <<< "$UNMET" || true)"

if [[ -n "$APP_UNMET" && -z "$NON_APP_UNMET" ]]; then
  warn "Mac App Store app(s) failed to install. You're probably not signed into App Store.app:"
  printf '%s\n' "$APP_UNMET"
  warn "Sign in to App Store.app, then run ./install.sh again to pick up the rest."
else
  err "Brew bundle failed. See output above."
  exit 1
fi
