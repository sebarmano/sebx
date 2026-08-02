#!/usr/bin/env sh
# common.sh — POSIX-safe shell config shared by zsh (Mac) and bash (Arch/Linux).
# Sourced by ~/.zshrc (Mac) and ~/.bashrc (Linux); do not execute directly.

# ── PATH additions ──────────────────────────────────────────────────────────
# Homebrew (macOS) — silently skip on Linux
if [ -d "/opt/homebrew/bin" ]; then
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# ── Core exports ────────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R"

# ── Aliases ─────────────────────────────────────────────────────────────────
alias vim="nvim"
alias vi="nvim"
alias ll="eza -lah --git"
alias ls="eza"
alias cat="bat --pager=never"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias g="git"
alias gst="git status"
alias gco="git checkout"
alias gcm="git commit -m"

# ── Tool initialisation ─────────────────────────────────────────────────────
# Detect the actual running shell rather than trying "bash init" and falling
# back to "zsh init" on failure: mise/zoxide/starship all happily emit
# bash-flavored init code on request regardless of which shell asked for it,
# so that fallback never actually triggers. Evaluating bash-only syntax
# (e.g. zoxide's `shopt -s promptvars`) under zsh then breaks with
# "command not found: shopt".
if [ -n "${ZSH_VERSION:-}" ]; then
  _SEBX_SHELL="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
  _SEBX_SHELL="bash"
fi

# mise (language version manager)
if [ -n "${_SEBX_SHELL:-}" ] && command -v mise >/dev/null 2>&1; then
  eval "$(mise activate "$_SEBX_SHELL" 2>/dev/null)"
fi

# zoxide (smarter cd)
if [ -n "${_SEBX_SHELL:-}" ] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init "$_SEBX_SHELL" 2>/dev/null)"
  alias cd="z"
fi

# fzf
if command -v fzf >/dev/null 2>&1; then
  if [ -f "${HOME}/.fzf.bash" ]; then
    # shellcheck source=/dev/null
    . "${HOME}/.fzf.bash"
  elif [ -f "${HOME}/.fzf.zsh" ]; then
    # shellcheck source=/dev/null
    . "${HOME}/.fzf.zsh"
  fi
fi

# starship prompt
if [ -n "${_SEBX_SHELL:-}" ] && command -v starship >/dev/null 2>&1; then
  eval "$(starship init "$_SEBX_SHELL" 2>/dev/null)"
fi

# ── macOS Keychain exports (macOS only) ─────────────────────────────────────
if [ "$(uname -s)" = "Darwin" ]; then
  _keychain_export() {
    local name="$1"
    local val
    val="$(security find-generic-password -a "$USER" -s "$name" -w 2>/dev/null || true)"
    [ -n "$val" ] && export "$name"="$val"
  }

  _keychain_export GITHUB_TOKEN
  _keychain_export OPENAI_API_KEY
  # _keychain_export ANTHROPIC_API_KEY
  # _keychain_export AWS_ACCESS_KEY_ID
  # _keychain_export AWS_SECRET_ACCESS_KEY
fi

# ── Local overrides (machine-specific, never committed) ──────────────────────
if [ -f "${HOME}/.config/shell/common.local.sh" ]; then
  # shellcheck source=/dev/null
  . "${HOME}/.config/shell/common.local.sh"
fi
