# Dotfiles managed by chezmoi

Near-identical setup on macOS (zsh + oh-my-zsh, Homebrew) and Omarchy (bash + Omarchy's rc layer).
Shared, in this repo: herdr, ghostty, git, starship, `~/.config/shell/{env,aliases,functions}.sh`, `~/.claude/CLAUDE.md`.
nvim (kickstart) is for macOS and the container role: Omarchy keeps its own LazyVim with theme hot-reload and remote clipboard, so `.config/nvim` is ignored on Omarchy machines.
Machine-local and unmanaged: `~/.config/shell/local.sh` (client project shortcuts; sourced by aliases.sh if present), `~/.gitconfig` (identity).
OS layer, not in this repo: Hyprland/omarchy on Linux; `~/.gitconfig` (identity, credential helpers) per machine.

## ~/.config/chezmoi/chezmoi.toml

```toml
[git]
autoCommit = false  # every machine commits with plain git in ~/.local/share/chezmoi
autoPush = false    # public repo, several writers: fetch before editing, push by hand

[data]
role = "desktop"    # "desktop" (GUI, 1Password SSH agent) | "server" (headless, key on disk)
                    # | "container" (shell image: offline, no nerd font, no 1Password)
                    # defaults to "desktop" via .chezmoidata.toml, so existing machines need no change
```

`role` is the only switch. Older `have_nerd_font`, `personal`, `offline`, `remote` keys in a machine's chezmoi.toml are ignored and can be dropped.

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

On Omarchy, `modify_dot_bashrc` appends the `~/.config/shell/*` source block to the Omarchy-owned `~/.bashrc` on apply; nothing to paste by hand.

## Server role (ser8)

`role = "server"` marks a headless, always-on machine reached over Tailscale/SSH.
There is no GUI 1Password there, so `~/.1password/agent.sock` never exists and the
agent-based SSH config cannot work. Instead the server renders a private key to disk
from 1Password, and `.chezmoiignore` keeps that key off every desktop.

Secrets come from 1Password service accounts (Agiler BV; the Family plan has none),
each scoped read-only to one vault:

| Vault | Holds | Read by |
|-------|-------|---------|
| `ser8-host` | ser8's ed25519 SSH key | provisioning (`chezmoi apply`) |
| `agents` | service tokens for every agent and dev shell, all machines | agent runtime (`op-agent`) |

Split deliberately: an agent on this box must not be able to read the SSH key.

The server's `~/.config/chezmoi/chezmoi.toml` must also declare service-account mode,
or chezmoi refuses to use the token:

```toml
[onepassword]
mode = "service"
```

Tokens live in 0600 files and are injected per process -- never exported from
`~/.config/shell/local.sh`, which every interactive shell (and every agent) inherits:

```sh
OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/ser8-provision.token)" chezmoi apply
```

For systemd units use `LoadCredential=` rather than `EnvironmentFile=`.

All machines reach the vault through `~/.local/bin/op-agent` (from this repo, role-templated):
on the server it injects the agent token for that one process, on desktops it adds `--account`.
Same command surface everywhere, so project `.env` files hold only `op://agents/<item>/<field>`
references and never name a machine. `~/.claude/CLAUDE.md` carries the rules.

ser8's key is a distinct GitHub identity, so revoking it never touches the laptops.

### Bootstrap runbook

Omarchy ISO: Ctrl+C in the install form toggles disk encryption -- leave it OFF for an
unattended-boot server (a LUKS prompt blocks boot until someone types; see git log).
Hostname `ser8`. Unencrypted installs get no SDDM autologin, which is what a server wants.

```sh
omarchy pkg add chezmoi ripgrep fd sd lazygit 1password-cli   # cli is not on a fresh install; `chezmoi apply` needs it
omarchy install service tailscale && sudo tailscale set --ssh   # delete the old ser8 node in the admin console first
omarchy toggle idle stay-awake     # always pass the mode: bare `toggle idle` flips it. Verify: omarchy toggle idle status
sudo loginctl enable-linger "$USER"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl enable --now btrfs-scrub@-.timer   # monthly checksum verify; unclean power cuts are the norm here
omarchy pkg add smartmontools                       # drive health: smartctl -a /dev/nvme0
install -d -m 700 ~/.config/op      # then place ser8-provision.token + ser8-agent.token, 0600, from 1Password
chezmoi init https://github.com/basvanwesting/dotfiles.git      # https: no SSH key yet
# write ~/.config/chezmoi/chezmoi.toml: role = "server", [onepassword] mode = "service", autoCommit/autoPush = false
OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/ser8-provision.token)" chezmoi apply
chezmoi git remote set-url origin git@github.com:basvanwesting/dotfiles.git
systemctl --user enable --now herdr-server.service             # unit file comes from this repo
```

Manual, outside chezmoi:
- herdr: the omarchy repo lags (0.8.2) and `/usr/bin` shadows `~/.local/bin` in both interactive and PAM PATH.
  Fetch the release into `~/.local/bin/herdr`, verify sha256 from https://herdr.dev/latest.json, then `sudo pacman -Rns herdr`.
  After `omarchy update`: `pacman -Q herdr` must say "not found" and `command -v herdr` must be `~/.local/bin/herdr`;
  if the package came back, `sudo pacman -Rns herdr` again.
  Updating: Mac client and ser8 server must run a compatible protocol (`herdr status server` shows it), so update both together.
  On ser8 replace the binary, then `systemctl --user restart herdr-server`; that restarts every pane, so do it when nothing runs there.
- Tailscale ACL: `ssh` rule `action: accept`, `users: [autogroup:nonroot]` (default `check` re-auths every 12h).
- Tailscale admin console, ser8 node: Disable key expiry. Node keys expire after 180 days; a headless box then drops off the tailnet until someone re-auths it locally. Independent of the ACL: expiry is node membership, the ACL is per-session login friction.
- 1Password GUI off, only if the installer put it there (a fresh 3.x install had neither GUI nor cli):
  `rm ~/.config/autostart/com.onepassword.OnePassword.desktop`, `omarchy pkg drop 1password` (keeps 1password-cli).
- Git identity: the Omarchy first-run wizard already wrote it to `~/.config/git/config`; no `~/.gitconfig` needed.
- `chezmoi init` works against a pre-existing clone in `~/.local/share/chezmoi` (no repo arg, nothing re-cloned).
- BIOS (Beelink SER8, AMI Aptio): Del at boot, Advanced > AMD CBS > FCH Common Options > AC Power Loss Options > Always On, F4 to save. Not under any Power/Chipset menu. Test: unplug while off, replug, it should boot. Unplug the install USB.
- If the install was encrypted anyway: `/etc/sddm.conf.d/zz-server.conf` with `[Autologin]` + empty `User=`.

## Tailscale

Not managed here: Omarchy and the macOS installer own it, and the node keys are machine state.

```sh
omarchy-install-service-tailscale   # Omarchy: package, tailscaled, --operator, Taildrop, bar plugin, admin webapp
tailscale set --ssh                 # only on machines that should accept Tailscale SSH (Linux-only feature)
```

macOS: standalone pkg from pkgs.tailscale.com (brew cask `tailscale-app` exists as an alternative, not used). The Mac is a client only.

## Keybinding rules

- Prefix/leader keys are identical on both: herdr `ctrl+b` (stock), nvim leader `space`. `prefix+ctrl+b` (prefix twice) sends a literal `ctrl+b`, built in.
- Actions (split, close, resize, rename tab, workspaces by number) stay on herdr's stock prefix chords. Navigation also gets a prefix-free Alt chord, identical on both machines: `alt+left/right` tabs, `alt+1..9` switch tab, `ctrl+alt+arrows` focus pane, `alt+up/down` workspaces. Super stays with Hyprland; on macOS ghostty maps left Option to Alt (`macos-option-as-alt = left`).
- Ghostty is only the outer terminal: all of its own tab/split binds are unbound on both OSes so herdr owns those chords.
