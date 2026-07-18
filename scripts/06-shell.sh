#!/usr/bin/env bash
# 06-shell.sh — configure the login shell and wire in common.sh.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

COMMON_SOURCE='[ -f "${HOME}/.config/shell/common.sh" ] && source "${HOME}/.config/shell/common.sh"'

if is_macos; then
  # ── macOS: use Homebrew zsh as login shell ────────────────────────────
  ZSH_PATH="$(brew --prefix)/bin/zsh"

  if ! grep -qF "$ZSH_PATH" /etc/shells; then
    log "Adding ${ZSH_PATH} to /etc/shells …"
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi

  if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    log "Changing login shell to ${ZSH_PATH} …"
    chsh -s "$ZSH_PATH"
    success "Login shell changed to ${ZSH_PATH}. Re-login to activate."
  else
    success "Login shell already ${ZSH_PATH}."
  fi

  # .zshrc is managed by stow (dotfiles/zsh/.zshrc); common.sh sourced within it.

elif is_linux; then
  # ── Arch/Linux: don't touch the login shell; just add common.sh to .bashrc ──
  BASHRC="${HOME}/.bashrc"
  log "Wiring common.sh into ${BASHRC} (preserving omarchy config) …"
  append_once "$COMMON_SOURCE" "$BASHRC"
  success "common.sh wired into .bashrc."
fi
