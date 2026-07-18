# .zshrc — macOS zsh config managed by sebx.
# Do not edit by hand; customise via ~/.zshrc.local instead.

# Shared aliases, exports, PATH, tool init
[ -f "${HOME}/.config/shell/common.sh" ] && source "${HOME}/.config/shell/common.sh"

# zsh-specific settings
setopt AUTO_CD
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${HOME}/.zsh_history"

# Machine-local overrides (not committed)
[ -f "${HOME}/.zshrc.local" ] && source "${HOME}/.zshrc.local"
