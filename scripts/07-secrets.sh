#!/usr/bin/env bash
# 07-secrets.sh — guided provisioning of secrets into macOS Keychain.
# Nothing secret is written to this repo. Add secret names to SECRETS array below.
set -euo pipefail
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=../lib/helpers.sh
source "${REPO}/lib/helpers.sh"

if ! is_macos; then
  warn "Not macOS — skipping Keychain secret provisioning."
  fancy_echo "Note: A Linux backend (e.g. libsecret / pass) can be added to this script later."
  exit 0
fi

# ── Add secret names here ─────────────────────────────────────────────────
SECRETS=(
  GITHUB_TOKEN
  OPENAI_API_KEY
  # ANTHROPIC_API_KEY
  # AWS_ACCESS_KEY_ID
  # AWS_SECRET_ACCESS_KEY
)

log "Provisioning secrets into macOS Keychain …"

for secret in "${SECRETS[@]}"; do
  if security find-generic-password -a "$USER" -s "$secret" -w &>/dev/null; then
    success "${secret} already in Keychain — skipping."
  else
    warn "${secret} not found in Keychain."
    printf 'Enter value for %s (input hidden): ' "$secret"
    read -rs value
    printf '\n'
    if [[ -n "$value" ]]; then
      security add-generic-password -a "$USER" -s "$secret" -w "$value" -U
      success "${secret} stored in Keychain."
    else
      warn "Empty value — skipping ${secret}."
    fi
  fi
done

success "Secrets provisioning complete."
fancy_echo "Verify a secret: security find-generic-password -a \"%s\" -s GITHUB_TOKEN -w" "$USER"
