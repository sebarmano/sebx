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

trap 'err "sebx failed while running ${script:-install.sh}. See output above."; exit 1' ERR

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
# Avoid `mapfile` (bash 4+): on a fresh Mac this runs on Apple's bundled
# bash 3.2 before Homebrew's own bash is installed.
declare -a SCRIPTS
SCRIPTS=()
if [[ $# -eq 0 ]]; then
  while IFS= read -r script; do
    SCRIPTS+=("$script")
  done < <(find "${REPO}/scripts" -name '*.sh' | sort)
else
  # Command substitution (not process substitution) so resolve_scripts's exit
  # status on an unknown keyword is actually visible here. Exiting inside a
  # process substitution subshell only kills that subshell, not install.sh.
  RESOLVED="$(resolve_scripts "$@")" || exit 1
  while IFS= read -r script; do
    SCRIPTS+=("$script")
  done < <(printf '%s\n' "$RESOLVED")
fi

# Bash 3.2 (Apple's bundled /bin/bash) treats "${SCRIPTS[@]}" on a legitimately
# empty array as an unbound variable under `set -u`. Guard before the loop
# below ever expands it and fail with a clear message instead of a crash.
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  err "No scripts to run."
  exit 1
fi

# ── Run ──────────────────────────────────────────────────────────────────────
fancy_echo "sebx bootstrap — running %d script(s)" "${#SCRIPTS[@]}"

for script in "${SCRIPTS[@]}"; do
  ensure_brew_on_path
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
