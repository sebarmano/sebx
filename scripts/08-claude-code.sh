#!/usr/bin/env bash
# 08-claude-code.sh — install Claude Code (Anthropic's official installer; not a brew package).
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if command_exists claude; then
  success "Claude Code already installed."
else
  log "Installing Claude Code …"
  curl -fsSL https://claude.ai/install.sh | bash
  success "Claude Code installed."
fi
