# Dotfiles managed by chezmoi

Near-identical setup on macOS (zsh + oh-my-zsh, Homebrew) and Omarchy (bash + Omarchy's rc layer).
Shared, in this repo: herdr, nvim, ghostty, git, starship, `~/.config/shell/{env,aliases,functions}.sh`, `~/.claude/CLAUDE.md`.
Machine-local and unmanaged: `~/.config/shell/local.sh` (client project shortcuts; sourced by aliases.sh if present), `~/.gitconfig` (identity).
OS layer, not in this repo: Hyprland/omarchy on Linux; `~/.gitconfig` (identity, credential helpers) per machine.

## ~/.config/chezmoi/chezmoi.toml

```toml
[git]
autoCommit = true
autoPush = true

[data]
have_nerd_font = true #boolean, use fancy fonts or not
personal = true       #boolean, whether machine is authenticated (e.g. github, copilot, docker)
offline = false       #boolean, has access to internet (e.g. disable auto-installs, auto-updates, github)
```

## Install (macOS)

```sh
brew install chezmoi
chezmoi init https://github.com/basvanwesting/dotfiles.git   # no --apply: write chezmoi.toml first, then `chezmoi diff`
chezmoi apply
brew bundle --global                                          # ~/.Brewfile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
mise install                                                  # runtimes from ~/.tool-versions
sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
```

## Install (Omarchy)

```sh
omarchy pkg add chezmoi ripgrep fd sd lazygit
chezmoi init https://github.com/basvanwesting/dotfiles.git   # no --apply
# write ~/.config/chezmoi/chezmoi.toml, then:
chezmoi diff
chezmoi apply
git config --file ~/.gitconfig user.name "..."               # identity is per machine, not in this repo
git config --file ~/.gitconfig user.email "..."
```

Then add to the "your own exports, aliases, and functions" section of `~/.bashrc`:

```sh
source ~/.config/shell/env.sh
source ~/.config/shell/aliases.sh
source ~/.config/shell/functions.sh
```

## Keybinding rules

- Prefix/leader keys are identical on both: herdr `ctrl+b` (stock), nvim leader `space`. `prefix+ctrl+b` (prefix twice) sends a literal `ctrl+b`, built in.
- Actions (split, close, resize, rename tab, workspaces by number) stay on herdr's stock prefix chords. Navigation also gets a prefix-free Alt chord, identical on both machines: `alt+left/right` tabs, `alt+1..9` switch tab, `ctrl+alt+arrows` focus pane, `alt+up/down` workspaces. Super stays with Hyprland; on macOS ghostty maps left Option to Alt (`macos-option-as-alt = left`).
- Ghostty is only the outer terminal: all of its own tab/split binds are unbound on both OSes so herdr owns those chords.
