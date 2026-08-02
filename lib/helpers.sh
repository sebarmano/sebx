#!/usr/bin/env bash
# lib/helpers.sh — shared logging, OS detection, idempotency helpers.
# Source this file; do not execute it directly.

# ── Logging ────────────────────────────────────────────────────────────────

log()     { printf '\n[sebx] \e[34m%s\e[0m\n' "$*"; }
warn()    { printf '\n[sebx] \e[33mWARN: %s\e[0m\n' "$*" >&2; }
success() { printf '\n[sebx] \e[32m✓ %s\e[0m\n' "$*"; }
err()     { printf '\n[sebx] \e[31mERROR: %s\e[0m\n' "$*" >&2; }

fancy_echo() {
  local fmt="$1"; shift
  # shellcheck disable=SC2059
  printf "\\n[sebx] ${fmt}\\n" "$@"
}

# ── OS / Arch detection ─────────────────────────────────────────────────────

is_macos() { [[ "$(uname -s)" == "Darwin" ]]; }
is_linux() { [[ "$(uname -s)" == "Linux" ]]; }
is_arm()   { [[ "$(uname -m)" == "arm64" || "$(uname -m)" == "aarch64" ]]; }

# ── Utility ─────────────────────────────────────────────────────────────────

command_exists() { command -v "$1" &>/dev/null; }

# ensure_brew_on_path: pick up brew if it's on disk but not yet in this
# process's PATH. Each scripts/*.sh runs as its own `bash "$script"` child of
# install.sh, so a PATH update made by one script (e.g. 01-preflight.sh right
# after installing Homebrew) never reaches its siblings — only install.sh's
# own process, and thus everything it spawns afterwards. Call this from
# install.sh before each script runs.
ensure_brew_on_path() {
  command_exists brew && return 0
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    if [[ -x "${prefix}/bin/brew" ]]; then
      eval "$("${prefix}/bin/brew" shellenv)"
      return 0
    fi
  done
  return 1
}

# append_once <line> <file>
# Adds <line> to <file> only if it is not already present.
append_once() {
  local line="$1"
  local file="$2"
  if ! grep -qF "$line" "$file" 2>/dev/null; then
    printf '\n%s\n' "$line" >> "$file"
    success "Appended to ${file}: ${line}"
  fi
}
