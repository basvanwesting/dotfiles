# Dotfiles managed by chezmoi

Near-identical setup on macOS (zsh + oh-my-zsh, Homebrew) and Omarchy (bash + Omarchy's rc layer).
Shared, in this repo: herdr, nvim, ghostty, git, starship, `~/.config/shell/{env,aliases,functions}.sh`, `~/.claude/CLAUDE.md`.
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
```

Then add to the "your own exports, aliases, and functions" section of `~/.bashrc`:

```sh
source ~/.config/shell/env.sh
source ~/.config/shell/aliases.sh
source ~/.config/shell/functions.sh
```

## Keybinding rules

- Prefix/leader keys are identical on both: herdr `ctrl+b` (stock), nvim leader `space`. `prefix+ctrl+b` (prefix twice) sends a literal `ctrl+b`, built in.
- Modifier chords belong to the OS layer: Cmd is free for herdr on macOS (`cmd+shift+[/]` tabs, `cmd+ctrl+[/]` workspaces, `cmd+1..9`); Super belongs to Hyprland, so Linux gets `ctrl+page_up/down` for tabs only.
