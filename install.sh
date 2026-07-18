#!/usr/bin/env bash
# install.sh — idempotent entrypoint for sebx.
# Usage: ./install.sh [script-keyword ...]
#   ./install.sh            — run all scripts in order
#   ./install.sh dotfiles   — run only 03-dotfiles.sh
#   ./install.sh brew languages — run 02-brew.sh and 05-languages.sh

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/helpers.sh
source "${REPO}/lib/helpers.sh"

trap 'err "sebx failed at line ${LINENO}. See output above."; exit 1' ERR

# ── Keyword → script mapping ─────────────────────────────────────────────────
# Maps human-readable keywords to script filenames (partial match on basename).
resolve_scripts() {
  local -a result=()
  for kw in "$@"; do
    local match
    match=$(find "${REPO}/scripts" -name "*${kw}*" -o -name "*-${kw}.sh" 2>/dev/null \
            | sort | head -1)
    if [[ -z "$match" ]]; then
      err "No script matching keyword: ${kw}"
      exit 1
    fi
    result+=("$match")
  done
  printf '%s\n' "${result[@]}"
}

# ── Determine which scripts to run ───────────────────────────────────────────
declare -a SCRIPTS
if [[ $# -eq 0 ]]; then
  mapfile -t SCRIPTS < <(find "${REPO}/scripts" -name '*.sh' | sort)
else
  mapfile -t SCRIPTS < <(resolve_scripts "$@")
fi

# ── Run ──────────────────────────────────────────────────────────────────────
fancy_echo "sebx bootstrap — running %d script(s)" "${#SCRIPTS[@]}"

for script in "${SCRIPTS[@]}"; do
  log "Running $(basename "$script") …"
  bash "$script"
done

# ── Extension hook (thoughtbot-style) ────────────────────────────────────────
LOCAL_HOOK="${HOME}/.sebx.local"
if [[ -f "$LOCAL_HOOK" ]]; then
  log "Sourcing local overrides from ${LOCAL_HOOK} …"
  # shellcheck source=/dev/null
  source "$LOCAL_HOOK"
fi

success "sebx complete! Open a new shell (or source ~/.zshrc) to pick up changes."
fancy_echo "Manual follow-ups (if any) are printed above under each script."
