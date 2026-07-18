# sebx

Personal, idempotent macOS bootstrap. One command to go from a fresh Mac to a fully
configured dev environment. Safe to re-run at any time.

## What it does

1. **Preflight** — installs Xcode CLT, Rosetta (Apple Silicon), and Homebrew.
2. **Brew** — installs CLI tools and GUI apps from `Brewfile`.
3. **Dotfiles** — symlinks configs for zsh, git, tmux, neovim, and starship via GNU Stow.
4. **macOS defaults** — applies sensible system tweaks (key repeat, screenshots, Finder, Dock).
5. **Languages** — installs `node@lts` (and others you configure) via `mise`.
6. **Shell** — sets Homebrew zsh as the login shell; wires a shared `common.sh` layer.
7. **Secrets** — guides you through storing API keys in macOS Keychain (never in the repo).

## Quick start (Mac)

```sh
# Clone the repo
git clone https://github.com/sebarmano/sebx.git ~/projects/sebx
cd ~/projects/sebx

# Run everything
./install.sh

# Or run individual steps
./install.sh brew dotfiles
```

Open a new terminal after running to pick up shell changes.

## Selective use on another machine (e.g. Arch Linux)

```sh
# Stow only the configs you want (dry-run first with -n):
cd ~/projects/sebx/dotfiles
stow -n -v -t ~ nvim tmux   # preview
stow    -v -t ~ nvim tmux   # apply
```

## Extending

See [AGENTS.md](AGENTS.md) for the full guide and copy-paste recipes for:

- Adding a Homebrew formula or cask
- Adding a dotfile package
- Adding a macOS default
- Adding a language runtime
- Adding a secret

### Machine-local overrides

Create these files (gitignored) for per-machine customisations:

| File | Purpose |
|---|---|
| `~/.zshrc.local` | Extra zsh config (Mac) |
| `~/.config/shell/common.local.sh` | Extra aliases/exports on any machine |
| `~/.gitconfig.local` | Git user name/email and machine-specific settings |
| `~/.sebx.local` | Extra bootstrap steps, sourced by `install.sh` at the end |

Example `~/.gitconfig.local`:
```ini
[user]
    name  = Your Name
    email = you@example.com
```

## Creating the GitHub remote

```sh
cd ~/projects/sebx
gh repo create sebx --private --source=. --remote=origin --push
```

## Verification

```sh
# Syntax check all scripts
bash -n install.sh scripts/*.sh lib/helpers.sh

# Stow dry-run (safe on any machine)
cd dotfiles && stow -n -v -t ~ nvim tmux

# Run install twice to confirm idempotency
./install.sh && ./install.sh
```
