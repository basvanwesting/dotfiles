# Dotfiles managed by chezmoi

One repo for every machine: macOS laptops, Omarchy desktops, a headless Omarchy server, and a
throwaway Linux shell image. Shared here: herdr, ghostty, git defaults, starship, nvim (kickstart),
`~/.config/shell/{env,aliases,functions}.sh`, `~/.claude/CLAUDE.md`, `~/.local/bin/op-agent`.
Machine-local and unmanaged: `~/.config/shell/local.sh` (client project shortcuts; sourced by
aliases.sh if present) and git identity (see the OS layer table). Hyprland/Omarchy config is Omarchy's.

## Two axes

**OS layer** is detected, never configured. `.chezmoi.os` separates macOS; on Linux
`.chezmoi.osRelease.id == "omarchy"` separates Omarchy from bare Linux.

| Layer | Shell stack | Owned by Omarchy, so ignored here | Git identity |
|-------|-------------|-----------------------------------|--------------|
| macOS | zsh, starship, nvim, `~/.Brewfile` | -- | `~/.gitconfig` |
| Omarchy | bash + Omarchy's rc layer; we only hook `~/.config/shell/*` into its `~/.bashrc` (`modify_dot_bashrc`) | `.zshrc`, `.config/nvim` (Omarchy's LazyVim has theme hot-reload and remote clipboard), `.config/git/config`, `.config/starship.toml` | `~/.config/git/config`, written by Omarchy's first-run wizard |
| bare Linux | same as macOS minus `~/.Brewfile` | -- | none needed |

Omarchy is a managed Linux: stay downstream of it and hook in, do not replace its files.
Bare Linux has nothing to stay downstream of, so it gets the full macOS-style stack.

**Role** is configured in chezmoi.toml and says what the machine is for. Default `desktop`
(from `.chezmoidata.toml`), so a desktop needs no chezmoi.toml at all.

| Role | Machines | Effect |
|------|----------|--------|
| `desktop` | laptops, Omarchy desktop | 1Password app authenticates; SSH via the 1Password agent, only `.pub` selector files on disk |
| `server` | ser8 | headless: ed25519 key rendered to disk from 1Password and every `~/.ssh/config` Host block uses it (no `IdentityAgent`), `op-agent` uses a service-account token, `.config/systemd/user/herdr-server.service` installed, server-specific rules in `~/.claude/CLAUDE.md` |
| `container` | shell image | assumed offline and viewed through someone else's terminal: no nerd-font glyphs, nvim treesitter auto-install and gitsigns off, no 1Password |

`role` is the only data variable. Older `have_nerd_font`, `personal`, `offline`, `remote` keys in a
machine's chezmoi.toml are ignored and can be dropped.

## ~/.config/chezmoi/chezmoi.toml

Only non-desktop roles need one. `autoCommit`/`autoPush` stay at chezmoi's default (off) everywhere.

```toml
[data]
role = "server"     # or "container"

[onepassword]       # server only: chezmoi refuses a service-account token without it
mode = "service"
```

## Workflow

Several machines commit to this public repo (the Mac and ser8 both did on the same day and
produced a rebase conflict), so:

```sh
chezmoi git pull -- --ff-only          # before editing, every time
chezmoi source-path ~/.config/foo      # find the source file, edit that, never the target
chezmoi diff && chezmoi apply
chezmoi git -- commit -am "..."        # plain git in ~/.local/share/chezmoi, no autoCommit
chezmoi git push                       # by hand, nothing leaves a machine unasked
```

Other machines: `chezmoi update` (pull + apply). On the server every chezmoi command that renders
templates (`update`, `apply`, `diff`, `verify`) needs the provisioning token, because the key template
calls `onepasswordRead` unconditionally; `chezmoi git ...` does not:

```sh
OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/ser8-provision.token)" chezmoi update
systemctl --user is-active herdr-server          # post-update check on ser8
```

If apply says a target "has changed since chezmoi last wrote it" and the content is what you
expect, `chezmoi apply --force`. To check what another
role or OS would render without that machine: `chezmoi --config <toml with that role> execute-template < <file>.tmpl`
on a machine with that OS (the Mac cannot render the Linux side of `.chezmoi.os`).

## Install (macOS)

```sh
brew install chezmoi
chezmoi init --apply https://github.com/basvanwesting/dotfiles.git   # desktop role needs no chezmoi.toml
brew bundle --global                                          # ~/.Brewfile
mise install                                                  # runtimes from ~/.tool-versions
sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
git config --file ~/.gitconfig user.name "..."               # identity is per machine, not in this repo
git config --file ~/.gitconfig user.email "..."
```

## Install (Omarchy desktop)

```sh
omarchy pkg add chezmoi ripgrep fd sd lazygit
chezmoi init --apply https://github.com/basvanwesting/dotfiles.git   # desktop role needs no chezmoi.toml
```

Git identity is already in `~/.config/git/config` from Omarchy's first-run wizard. The shell source
block lands in Omarchy's `~/.bashrc` on apply; nothing to paste by hand. For a server see below.

## Install (container)

In the image's Dockerfile, after installing `chezmoi`, `git`, `zsh`, `neovim`:

```sh
chezmoi init https://github.com/basvanwesting/dotfiles.git
printf '[data]\nrole = "container"\n' > ~/.config/chezmoi/chezmoi.toml
chezmoi apply
```

Then `git clone https://github.com/zsh-users/zsh-autosuggestions ~/.local/share/zsh-autosuggestions` and pre-sync nvim plugins at build time
(`nvim --headless "+Lazy! sync" +qa`), because at run time the image is assumed offline.

## Secrets (1Password)

Every API key or token an agent or dev shell needs is a field on an item in the `agents` vault
(Agiler BV account). Projects commit a dotenv of references, never values
(`MAILGUN_API_KEY=op://agents/mailgun/MAILGUN_API_KEY`), and run the consumer under
`op-agent run --env-file .env -- <cmd>`. `~/.local/bin/op-agent` comes from this repo and is
role-templated so the command surface is the same on every machine and no project names a machine:

- desktop: the 1Password app authenticates; `op-agent` adds `--account` (two accounts are linked, so it is mandatory).
  SSH keys also live in 1Password: `IdentityAgent` in `~/.ssh/config`, only `.pub` selector files on disk.
- server: no GUI, so service accounts (Agiler BV; the Family plan has none), each scoped read-only to one vault:

| Vault | Holds | Read by |
|-------|-------|---------|
| `ser8-host` | ser8's ed25519 SSH key | provisioning (`chezmoi apply`) |
| `agents` | service tokens for every agent and dev shell, all machines | agent runtime (`op-agent`) |

Split deliberately: an agent on the server must not be able to read the SSH key. The two tokens
live as 0600 files in `~/.config/op` (next to op's own `config`) and are injected per process, never
exported from a shell rc file such as `~/.config/shell/local.sh`, which every interactive shell (and
every agent) would inherit:

```sh
OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/ser8-provision.token)" chezmoi apply
```

Rule for any future systemd unit that needs a secret (none does today; `herdr-server.service` has
none): `LoadCredential=` rather than `EnvironmentFile=`. `~/.claude/CLAUDE.md` carries the
day-to-day rules for agents.

## Server role (ser8)

`role = "server"` marks a headless, always-on machine reached over Tailscale/SSH. There is no GUI
1Password there, so `~/.1password/agent.sock` never exists and the agent-based SSH config cannot
work. Instead the server renders a private key to disk from the `ser8-host` vault, and
`.chezmoiignore` keeps that key off every other role. ser8's key is its own key on the GitHub account, so
revoking it never touches the laptops.

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
# write ~/.config/chezmoi/chezmoi.toml: role = "server", [onepassword] mode = "service"
OP_SERVICE_ACCOUNT_TOKEN="$(< ~/.config/op/ser8-provision.token)" chezmoi apply
chezmoi git remote set-url origin git@github.com:basvanwesting/dotfiles.git
systemctl --user enable --now herdr-server.service             # unit file comes from this repo
```

Manual, outside chezmoi:
- herdr: Omarchy stable lags upstream (0.8.2 vs 0.9.1 on 2026-09-21); install the same package from
  Omarchy's edge channel instead, see "herdr ahead of Omarchy stable" below. Never a hand-copied binary in
  `~/.local/bin`: Omarchy's herdr migration deletes it and re-adds the package on purpose.
- Tailscale ACL: `ssh` rule `action: accept`, `users: [autogroup:nonroot]` (default `check` re-auths every 12h).
- Tailscale admin console, ser8 node: Disable key expiry. Node keys expire after 180 days; a headless box then drops off the tailnet until someone re-auths it locally. Independent of the ACL: expiry is node membership, the ACL is per-session login friction.
- 1Password GUI off, only if the installer put it there (a fresh 3.x install had neither GUI nor cli):
  `rm ~/.config/autostart/com.onepassword.OnePassword.desktop`, `omarchy pkg drop 1password` (keeps 1password-cli).
- Git identity: the Omarchy first-run wizard already wrote it to `~/.config/git/config`; no `~/.gitconfig` needed.
- `chezmoi init` works against a pre-existing clone in `~/.local/share/chezmoi` (no repo arg, nothing re-cloned).
- BIOS (Beelink SER8, AMI Aptio): Del at boot, Advanced > AMD CBS > FCH Common Options > AC Power Loss Options > Always On, F4 to save. Not under any Power/Chipset menu. Test: unplug while off, replug, it should boot. Unplug the install USB.
- If the install was encrypted anyway: `/etc/sddm.conf.d/zz-server.conf` with `[Autologin]` + empty `User=`.

### herdr ahead of Omarchy stable (decided 2026-09-21, ser8 on edge since 2026-09-26)

Decision: **Omarchy edge package** (B), not a direct binary (A). Reasons: Omarchy's herdr migration
(`/usr/share/omarchy/migrations/1786273938.sh`) and `omarchy-reinstall-pkgs` both delete
`~/.local/bin/herdr` and re-add the package on purpose, so A is undone by every Omarchy update; edge is
signed, pacman-tracked, and `omarchy update` never downgrades, so stable takes over by itself once it
passes edge. Tested on the Omarchy laptop since 2026-09-18 (downgrade with `pacman -S omarchy/herdr`,
back up with `-U` from edge).

The unit is path-agnostic since this decision: `ExecStart=/bin/bash -lc 'exec herdr server'` resolves
to `/usr/bin/herdr` under B and to `~/.local/bin/herdr` under A (the package is absent then), so no
dotfiles change is needed if A is ever required again. A stays the escape hatch for a version edge
lacks; then use `herdr update`, the supported updater for a direct install, not a manual fetch.

Check what edge has, then install or bump (restarts every pane):

```sh
curl -fsSL https://pkgs.omarchy.org/edge/x86_64/omarchy.db | bsdtar -tf - | grep '^herdr'
sudo pacman -U https://pkgs.omarchy.org/edge/x86_64/herdr-<version>-1-x86_64.pkg.tar.zst
systemctl --user restart herdr-server
herdr status server && command -v herdr              # protocol must match the Mac client; /usr/bin/herdr
```

Mac side: the client is a direct install (`herdr update`) and must share a protocol with ser8's server.
Before updating the Mac, check that edge already has that version; if it does not, wait. Both sides
are on 0.9.1 / protocol 22 as of 2026-09-21.

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
