# AGENTS.md — AI agent guide for sebx

> Read this before modifying the repo. It applies to any AI agent or coding assistant
> (Claude Code, Cursor, Copilot, etc.).

## What this project is

**sebx** is a personal, idempotent macOS bootstrap tool. It installs CLI tools, GUI apps,
shell config, dotfiles, language runtimes, and macOS system defaults from a single command:
`./install.sh`. It is designed to be safe to re-run at any time.

**Philosophy:**
- macOS is the primary target; Arch/Linux is supported for shared configs only.
- Secrets never enter the repo — they live in macOS Keychain.
- Every script must be idempotent (safe to run twice with no side effects).
- Dotfiles are managed by GNU Stow; each tool gets its own package directory.

## Repo map

| Path | Purpose |
|---|---|
| `install.sh` | Main entrypoint — orchestrates all scripts |
| `Brewfile` | Homebrew formulae and casks |
| `lib/helpers.sh` | Shared logging, OS detection, idempotency helpers |
| `scripts/01-preflight.sh` | Xcode CLT, Rosetta, Homebrew install |
| `scripts/02-brew.sh` | `brew bundle` from Brewfile |
| `scripts/03-dotfiles.sh` | Stow all dotfile packages |
| `scripts/04-macos-defaults.sh` | `defaults write` system tweaks (macOS only) |
| `scripts/05-languages.sh` | Install language runtimes via mise |
| `scripts/06-shell.sh` | Set login shell (Mac) / wire common.sh (Linux) |
| `scripts/07-secrets.sh` | Provision secrets into macOS Keychain |
| `scripts/08-claude-code.sh` | Install Claude Code (Anthropic's own installer, not brew) |
| `dotfiles/shell/.config/shell/common.sh` | Shared POSIX aliases/exports/PATH/tool-init |
| `dotfiles/zsh/.zshrc` | zsh config (Mac); sources common.sh + ~/.zshrc.local |
| `dotfiles/git/.gitconfig` | Git config; includes ~/.gitconfig.local |
| `dotfiles/git/.config/git/ignore` | Global gitignore |
| `dotfiles/tmux/.config/tmux/tmux.conf` | tmux config |
| `dotfiles/nvim/.config/nvim/` | LazyVim config: Python (pyright+ruff+black), Ruby (ruby_lsp+standardrb), web/TS |
| `dotfiles/starship/.config/starship.toml` | Starship prompt config |
| `AGENTS.md` | This file — AI agent guide |
| `CLAUDE.md` | Thin pointer to this file (Claude Code reads it) |
| `README.md` | Human-facing usage docs |

## Golden rules

1. **Always source `lib/helpers.sh`** at the top of every script in `scripts/`.
2. **Guard OS-specific code** with `is_macos` / `is_linux` helpers — never assume macOS.
3. **Never write secrets** to any file in the repo. Use `07-secrets.sh` and macOS Keychain.
4. **Keep everything idempotent.** Check-before-act; use `--restow`, `append_once`, etc.
5. **Match existing script style**: `set -euo pipefail`, log with `log`/`success`/`warn`/`err`.
6. **Add dotfiles via Stow packages** — never symlink directly or copy into `$HOME`.
7. `ai_docs/` is gitignored and must never be committed.

## How to extend — copy-paste recipes

### Add a CLI tool
```sh
# In Brewfile, under "# ── CLI tools":
brew "your-tool"
# Verify (on Mac):
brew bundle check --file=Brewfile
```

### Add a GUI app (cask)
```sh
# In Brewfile, under "# ── GUI apps (casks)":
cask "your-app"
```

### Add a Mac App Store app (mas)
```sh
# Find the app's ID:
# - If it's already installed: mdls -name kMDItemAppStoreAdamID "/Applications/App Name.app"
# - Otherwise: mas search "App Name"

# In Brewfile, under "# ── Mac App Store (requires: brew "mas")":
mas "App Name", id: 123456789
```
Note: `mas` can't sign in on its own. The machine must already be signed into
App Store.app with the Apple ID that purchased the app, or this entry fails silently
on `brew bundle`.

### Add a dotfile package
```sh
# 1. Create the package directory mirroring $HOME layout:
mkdir -p dotfiles/myapp/.config/myapp
echo "config content" > dotfiles/myapp/.config/myapp/config

# 2. Register it in scripts/03-dotfiles.sh PACKAGES array:
# PACKAGES=(shell zsh git tmux nvim starship myapp)

# 3. Dry-run to preview symlinks:
cd dotfiles && stow -n -v -t ~ myapp
```

### Add a macOS default
```sh
# Append to scripts/04-macos-defaults.sh with a comment:
defaults write com.example.app SomePref -bool true
```

### Add a language runtime
```sh
# In scripts/05-languages.sh:
mise use --global python@latest
```

### Add a secret
```sh
# 1. Add the name to the SECRETS array in scripts/07-secrets.sh
# 2. Add an export in dotfiles/shell/.config/shell/common.sh (macOS-guarded):
#    _keychain_export MY_SECRET_NAME
```

## Verification checklist

Run before finishing any change:

```sh
# Syntax check
bash -n install.sh scripts/*.sh lib/helpers.sh

# Lint (if shellcheck available)
shellcheck install.sh scripts/*.sh lib/helpers.sh

# Stow dry-run (safe on any machine)
cd dotfiles && stow -n -v -t ~ nvim tmux

# Smoke-test common.sh (bash)
bash -c 'source dotfiles/shell/.config/shell/common.sh && echo OK'
```
