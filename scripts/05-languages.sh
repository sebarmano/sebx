#!/usr/bin/env bash
# 05-languages.sh — install language runtimes via mise.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if ! command_exists mise; then
  err "mise not found. Run 02-brew.sh first (or install mise manually)."
  exit 1
fi

log "Installing language runtimes via mise …"

# Add runtimes here. Each call is idempotent — mise skips already-active versions.
mise use --global node@lts
# mise use --global python@latest
# mise use --global ruby@latest
# mise use --global go@latest

success "Language runtimes installed."
mise list
