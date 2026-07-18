#!/usr/bin/env bash
# 03-dotfiles.sh — stow dotfile packages into $HOME.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if ! command_exists stow; then
  err "GNU Stow not found. Install it (brew install stow / pacman -S stow) and retry."
  exit 1
fi

DOTFILES_DIR="${REPO}/dotfiles"
PACKAGES=(shell zsh git tmux nvim starship)

log "Stowing dotfile packages into ${HOME} …"
cd "$DOTFILES_DIR"

for pkg in "${PACKAGES[@]}"; do
  if [[ ! -d "$pkg" ]]; then
    warn "Package '${pkg}' not found in dotfiles/ — skipping."
    continue
  fi

  # --restow removes then re-adds symlinks; safe to re-run.
  stow --target="$HOME" --restow "$pkg"
  success "Stowed: ${pkg}"
done

success "All dotfile packages stowed."
fancy_echo "Tip: On another machine, stow selectively: cd dotfiles && stow -t ~ nvim tmux"
