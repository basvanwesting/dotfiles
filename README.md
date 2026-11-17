# Dotfiles managed by chezmoi

One repo for every machine: macOS laptops, Omarchy desktops, a headless Omarchy server, and a
throwaway Linux shell image. Shared here: herdr, ghostty, git defaults, starship, nvim (kickstart),
`~/.config/shell/{env,aliases,functions}.sh`, `~/.claude/CLAUDE.md`, `~/.local/bin/op-agent`.
Machine-local and unmanaged: `~/.config/shell/local.sh` (client project shortcuts; sourced by
aliases.sh if present) and git identity (see the OS layer table). Hyprland/Omarchy config is Omarchy's;
the mail and calendar window groups hook in beside it (see "Mail and calendar on Omarchy").

## Machines

| Machine | OS / role | Used for |
|---------|-----------|----------|
| ser9 | Omarchy, `desktop` (monitor attached) | main development machine at the office; runs agents (since 2026-11-12) |
| MacBook Pro | macOS, `desktop` | main personal development machine; runs agents. Being phased out, to become an Omarchy gliff thin client |
| ser8 | Omarchy, `server` (headless) | always-on server over Tailscale/SSH/gliff; runs agents, see [Server role](#server-role-ser8) |
| MacBook Air | Omarchy, `client` | a screen to work from; no agents |
| mitx-omg | Omarchy, `client` | home PC with the big screen and GPU, second boot next to Windows, mostly off; no agents |

ser9 and the MacBook Pro are used the same way, so a setup step for one is a setup step for the other.

## Two axes

**OS layer** is detected, never configured. `.chezmoi.os` separates macOS; on Linux
`.chezmoi.osRelease.id == "omarchy"` separates Omarchy from bare Linux.

| Layer | Shell stack | Owned by Omarchy, so ignored here | Git identity |
|-------|-------------|-----------------------------------|--------------|
| macOS | zsh, starship, nvim, `~/.Brewfile`, himalaya | -- | `~/.gitconfig` |
| Omarchy | bash + Omarchy's rc layer; we only hook `~/.config/shell/*` into its `~/.bashrc` (`modify_dot_bashrc`) and one include into its `~/.config/git/config` (`modify_config`) | `.zshrc`, `.config/starship.toml` | `~/.config/git/config`, written by Omarchy's first-run wizard |
| bare Linux | same as macOS minus `~/.Brewfile` | -- | none needed |

Omarchy is a managed Linux: stay downstream of it and hook in, do not replace its files.
Bare Linux has nothing to stay downstream of, so it gets the full macOS-style stack.

### Neovim on Omarchy (decided 2026-11-10)

The exception to "do not replace": `~/.config/nvim` is our kickstart config on Omarchy too, and the
`omarchy-nvim` package (a LazyVim starter) is removed. Omarchy 4 allows for this: the package's
setup never overwrites an existing `~/.config/nvim`, `omarchy update` does not reinstall dropped base
packages, and the theme reaches nvim only as a file any config can read. The package goes because
its `omarchy-nvim-refresh` would overwrite our config and its 79 MB plugin seed is unused. Its
migrations target LazyVim paths (`lua/config/`, `lua/plugins/theme.lua`) our layout lacks, so they
would mostly no-op either way.

Risk of dropping it: an nvim migration that copies from `/usr/share/omarchy-nvim` without checking
the package fails, and `omarchy-migrate` stops at the first failure, blocking every later one. Such a
migration targets LazyVim, so skip it: `touch ~/.local/state/omarchy/migrations/<name>.sh`.

What Omarchy's LazyVim had is ported, as plain Lua:

- theme follows the desktop theme: `lua/custom/omarchy/` (Omarchy only; the theme symlink into
  `~/.local/state/omarchy/current/theme/neovim.lua`, every colorscheme an Omarchy theme can name,
  and the hot reload on theme switch). Imported as a directory because lazy only watches imported
  spec files for changes. Each file names the `omarchy-nvim` version it was ported from; after an
  Omarchy update that breaks theming, diff against the current package (`pacman -Sw omarchy-nvim`,
  unpack it from `/var/cache/pacman/pkg`).
- remote clipboard (`lua/remote_clipboard.lua`): on every OS, pbcopy added for macOS. Inside herdr,
  tmux or ssh a yank also goes out as OSC 52, so a yank on ser8 lands on the laptop.
- not ported: the transparency and lualine tweaks.

### Mail and calendar on Omarchy (decided 2026-11-16)

Mail and calendars are Omarchy web apps, one window per account, held together as tabbed Hyprland
window groups: `~/.config/hypr/webapp-group` (its header has the lists and why no native client).
It ships to every Omarchy machine but the server. Hyprland's own files stay Omarchy's, so ours sit
beside them and each machine does the rest by hand. The first line again after
`omarchy refresh hyprland`, which rewrites `hyprland.lua` (the keys falling back to HEY is the sign):

```sh
echo 'require("hypr.webapp-groups")' >> ~/.config/hypr/hyprland.lua   # the keys; replaces the HEY defaults
xdg-mime default mail-compose.desktop x-scheme-handler/mailto
```

- Logins live in a Chromium profile of their own (`~/.config/chromium-mail`), never in this repo.
  Gmail tabs go by account index, so the files name no address, and the tab order on a machine
  follows the order the accounts were signed in there. Sign in in the same order everywhere.
- The one file with addresses, `webapp-group-titles/labels.js`, is machine-local: chezmoi creates it
  empty (`create_`) and `apply` never overwrites it. Fill in the Outlook addresses by hand. This repo
  is public; an address belongs in that file or nowhere. `chezmoi add` on it would copy the real file
  into the source, so `.gitignore` keeps that copy out of a commit.
- If Chromium offers to handle email links, decline: accepting hands `mailto:` to the normal browser.
- After changing `titles.js`: `node dot_config/hypr/webapp-group-titles/titles.test.js` in the source.
  It reaches the extension only when the mail browser restarts, with every window of it closed.

**Role** is configured in chezmoi.toml and says what the machine is for. Default `desktop`
(from `.chezmoidata.toml`), so a desktop needs no chezmoi.toml at all.

| Role | Machines | Effect |
|------|----------|--------|
| `desktop` | MacBook Pro, ser9 | SSH via the 1Password agent, only `.pub` selector files on disk. Agents work here: service-account token, accepts Tailscale SSH |
| `client` | MacBook Air, mitx-omg | as `desktop` for me, but no agents: no service-account token, Tailscale shields up, no SSH server. The dotfiles render the same; the difference is what [`fleet-check`](#fleet-check) expects |
| `server` | ser8 | headless: no SSH key and no `IdentityAgent`, so ssh works only through an agent forwarded by the user (`ssh -A`), `.config/systemd/user/herdr-server.service` installed, server-specific rules in `~/.claude/CLAUDE.md` |
| `container` | shell image | assumed offline and viewed through someone else's terminal: no nerd-font glyphs, nvim treesitter auto-install and gitsigns off, no 1Password |

`role` is the only data variable. Older `have_nerd_font`, `personal`, `offline`, `remote` keys in a
machine's chezmoi.toml are ignored and can be dropped.

## ~/.config/chezmoi/chezmoi.toml

Every role but `desktop` needs one. `autoCommit`/`autoPush` stay at chezmoi's default (off) everywhere.

```toml
[data]
role = "server"     # or "client", "container"
```

## Workflow

Several machines commit to this public repo (the Mac and ser8 both did on the same day and
produced a rebase conflict), so:

```sh
dotup                                  # before editing, every time (review + apply, below)
chezmoi source-path ~/.config/foo      # find the source file, edit that, never the target
chezmoi diff && chezmoi apply
chezmoi git -- commit -am "..."        # plain git in ~/.local/share/chezmoi, no autoCommit
chezmoi git push                       # by hand, nothing leaves a machine unasked
```

Other machines: `dotup` (in `~/.config/shell/functions.sh`), never `chezmoi update`. Every machine
applies `main`, and that writes `~/.local/bin/op-agent`, the shell rc layer and the agents' `~/.claude/`
instructions. A pushed commit is therefore code on all of them, and agents push here too (`/my-learn`).
`dotup` fetches, shows every incoming commit in full, and fast-forwards plus applies only after a yes.
Read the diff, not just the subjects. Push access is kept narrow (decided 2026-11-12, security review):

- `GH_TOKEN_PERSONAL` (the `agents` vault, readable by every machine's agent token) has no write
  access to this repo. Pushes go over SSH through the 1Password agent, which asks for approval.
  Fetch goes over https with that token, so an agent's fetch never touches my key. Both follow
  from the global git config, not from this repo's remote, see [Git and GitHub](#git-and-github).
- A ruleset on `main` blocks force-pushes and deletion, so history can't be rewritten to hide a commit.

The server has no key and no agent, so it cannot push by itself: it fetches over https and its push
goes over SSH, which only works with an agent forwarded from a desktop, see "Server role (ser8)".

```sh
dotup
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
mise install                                                  # tools from ~/.config/mise/config.toml
sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
git config --file ~/.gitconfig user.name "..."               # identity is per machine, not in this repo
git config --file ~/.gitconfig user.email "..."
```

Then give the machine its `op-agent` token, see [Secrets](#secrets-1password).

## Install (Omarchy desktop)

```sh
omarchy pkg add chezmoi ripgrep fd sd lazygit
omarchy pkg add syncthing                           # on machines that hold ~/Sync, then see "Syncthing"
# neovim is only a dependency of omarchy-nvim; `pkg drop` is `pacman -Rns` and would take it along.
sudo pacman -D --asexplicit neovim && omarchy pkg drop omarchy-nvim   # see "Neovim on Omarchy"
# LazyVim's config and its 260 MB plugin/mason data live in nvim's dirs, which ours reuses; set them aside.
for d in .config/nvim .local/share/nvim .local/state/nvim .cache/nvim; do mv ~/$d ~/$d.omarchy; done
chezmoi init --apply https://github.com/basvanwesting/dotfiles.git   # desktop role needs no chezmoi.toml
mise install                                                  # tools from ~/.config/mise/config.toml
```

Git identity normally comes from Omarchy's first-run wizard and lives in `~/.config/git/config`. If
`git config user.name` is empty, set it there. The shell source block lands in Omarchy's `~/.bashrc`
on apply; nothing to paste by hand. `chezmoi apply` replaces Omarchy's stock ghostty and herdr configs
(herdr's prefix goes from Omarchy's `ctrl+space` to stock `ctrl+b`). Optionally pre-sync the nvim plugins
with `nvim --headless "+Lazy! sync" +qa`. For a server see below.

MacBook with an ISO keyboard (e.g. Dutch): `hid_apple` auto-detects ISO and swaps the key left of Z
(`` `~ ``) with the top-left one (`§±`). Turn the swap off; the module loads from the initramfs, so rebuild it:

```sh
echo "options hid_apple fnmode=2 iso_layout=0" | sudo tee /etc/modprobe.d/hid_apple.conf
sudo limine-mkinitcpio
```

Mail and calendar keys: two lines by hand, see [Mail and calendar on Omarchy](#mail-and-calendar-on-omarchy-decided-2026-11-16).

Hyprland overrides: Hyprland config is Omarchy's, so append these to `~/.config/hypr/input.lua` by hand.

- Caps Lock as Ctrl. Replaces Omarchy's `omarchy:shift_caps_compose` (Shift + Caps Lock = compose), so
  there is no compose key; both Shifts together still toggle Caps Lock.
- Laptop only, tap-to-click off: a finger resting on the trackpad otherwise clicks, and a click focuses
  the window under the pointer.
- Pointer to the centre of a window that opens with focus (decided 2026-11-11). Focus follows the mouse,
  so a pointer left over the previous window hands focus back to it at the first movement.
  `follow_mouse_threshold` was tried first and dropped: it only delays the same steal.

```lua
hl.config({
  input = {
    kb_options = "ctrl:nocaps,shift:both_capslock_cancel",
    touchpad = { tap_to_click = false },   -- laptop only
  },
})

hl.on("window.open", function(window)
  -- The layout places the window after this event; read its box once it has.
  hl.timer(function()
    local active = hl.get_active_window()
    if not active or active.address ~= window.address then return end
    hl.dispatch(hl.dsp.cursor.move({
      x = math.floor(window.at.x + window.size.x / 2),
      y = math.floor(window.at.y + window.size.y / 2),
    }))
  end, { type = "oneshot", timeout = 50 })
end)
```

T2 MacBook (Air 2020): S3 deep sleep woke within seconds, and with the lid shut logind re-suspends
every ~30 s; the loop drained a full battery overnight (2026-11-10, ~1000 cycles). Two wake sources,
found by bisecting `/proc/acpi/wakeup` (2026-11-11):

- `TXHC` (Thunderbolt xHCI, `00:0d.0`, its own GPE `0x73`): wakes it with the lid open.
- `ARPT` (BCM4377b Wi-Fi, `73:00.0`, GPE `0x69`): wakes it with the lid shut. brcmfmac re-enables its
  wake on every resume, so a boot-time udev rule loses; the unit re-disables before every sleep.

Several devices share a GPE (`RP01`/`RP05`/`ARPT` on `0x69`, `LID0`/`EC`/`ADP1` on `0x6F`), which made
single-device bisecting misleading; the rest keep their wake (lid, keyboard, power button). Not the
BCM4377b failure from Omarchy discussion #4695 (D3 timeout, suspend aborts with -5): here every suspend
succeeded and was then woken. Should that one appear, unloading `brcmfmac_wcc brcmfmac` around sleep
is the reported fix. A unit, not a hook: systemd 262 only runs hooks from `/usr/lib/systemd/system-sleep/`.

```sh
sudo tee /etc/systemd/system/t2-no-spurious-wake.service <<'EOF'
[Unit]
Description=Disable Thunderbolt and Wi-Fi wake before sleep (T2 S3 wake loop)
Before=sleep.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'for d in 0000:00:0d.0 0000:73:00.0; do echo disabled > /sys/bus/pci/devices/$d/power/wakeup; done'

[Install]
WantedBy=sleep.target
EOF
sudo systemctl enable t2-no-spurious-wake.service
```

Every Omarchy desktop then sets up the 1Password app for SSH and the user's own `op`:

```sh
omarchy install service 1password        # sign in, then Settings > Developer:
                                         # "Use the SSH agent" + "Integrate with 1Password CLI"
# Omarchy has no ssh-askpass, so the first connection can't prompt for the host key
# ("Host key verification failed"); accept it on first use.
ssh -o StrictHostKeyChecking=accept-new -T git@github.com   # check: "Hi basvanwesting!"
op --account agilerbv.1password.com vault list   # two accounts, so bare `op` needs --account
```

A desktop that runs agents (ser9, like the MacBook Pro) also needs its `op-agent` token, see
[Secrets](#secrets-1password); the git wiring comes with `chezmoi apply`. A desktop without agents skips both; the
1Password app handles all auth.

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

Every API key or token that active work by an agent or dev shell needs is a field on an item in the `agents` vault
(Agiler BV account). Projects commit a dotenv of references, never values
(`ENGAGE_API_KEY=op://agents/engage/ENGAGE_API_KEY`), and run the consumer under
`op-agent run --env-file .env -- <cmd>`. `~/.local/bin/op-agent` comes from this repo and is the
same on every machine, so no project names a machine. It authenticates with a service account
(Agiler BV; the Family plan has none), never with the desktop app: the app authorizes a CLI for the
whole account, a service account is scoped read-only to one vault and never prompts.

| Vault | Holds | Read by |
|-------|-------|---------|
| `ser8-host` | backup copy of ser8's `agents` token | nobody (no service account) |
| `agents` | service tokens for the work that is active now, all machines | agent runtime (`op-agent`) |
| `agents-disabled` | `agents` items parked while not in use; moved back for as long as the work takes | nobody (no service account), so a stolen or misled machine can't read them |

- every machine: its own `agents` service account (revocable per machine), token in
  `~/.config/op/agent.token`. A new secret is a new item or field in `agents`, made in the app; a
  service account's vault list is fixed at creation. A backup copy of a token never goes into
  `agents` (every other machine's token could read it, which defeats revoking one machine): ser8's
  sits in `ser8-host`.
  By hand, once per machine, or `op-agent` refuses to run (bare `op` here is the app, so one
  whole-account prompt):

  ```sh
  (umask 077; install -d -m 700 ~/.config/op; op --account agilerbv.1password.com service-account create "$(hostname -s)-agent service account" --vault agents:read_items --raw > ~/.config/op/agent.token)
  op-agent vault list                     # check: only `agents`
  ```

  The desktop app doesn't show service accounts. To find or revoke one, go to agilerbv.1password.com >
  Developer > Directory.
- desktop: SSH keys also live in 1Password: `IdentityAgent` in `~/.ssh/config`, only `.pub` selector
  files on disk. Bare `op` is still the app, for the user's own whole-account use.
- server: no GUI and no SSH key. An agent there runs as the user, so a key file (or a token that can
  fetch one) is readable by every agent whatever its mode; a key rendered to disk from `ser8-host`
  was removed 2026-11-16 for that reason.

Tokens live as 0600 files in `~/.config/op` (next to op's own `config`) and are injected per process,
never exported from a shell rc file such as `~/.config/shell/local.sh`, which every interactive shell
(and every agent) would inherit.

GitHub over https uses the same vault: item `github` holds one fine-grained PAT per repo owner
(`GH_TOKEN_FOURSTACK`, `GH_TOKEN_PERSONAL`; a fine-grained PAT covers a single owner), and
`~/.local/bin/git-credential-op-agent` hands git the one matching the owner in the URL. `~/.local/bin/gh-agent`
does the same for `gh` (owner from `-R`/`GH_REPO`, else an `OWNER/...` argument, else the `origin`
remote); it is its own command, not a shadow of `gh`, so it does not depend on `PATH` order.
Bare `gh` gets no vault PAT and stays logged out on every machine: its login is a classic token for
every repo, readable by any process, which would undo the per-owner PATs. Whatever calls it directly
(ghui, a tool's built-in `gh` use) runs unauthenticated.
A new owner is a new field plus a line in `~/.local/bin/github-pat-field`, the map both share.
A passkey cannot do this: it signs in a browser, not git.

### Git and GitHub

Reading is the agents' authority, writing is mine, and the global git config says so once for every
clone (`~/.config/git/github.inc`, included from `~/.config/git/config`; desktop and server roles):

| A GitHub remote spelled | fetches from | pushes to |
|---|---|---|
| `https://github.com/o/r` | https, vault PAT | `ssh://git@github.com/o/r`, my key |
| `git@github.com:o/r` | https, vault PAT | `ssh://git@github.com/o/r`, my key |
| `ssh://git@github.com/o/r` | SSH, my key | SSH, my key |

- An agent's fetch or clone never touches my key, so it raises no 1Password prompt, and the keyless
  server can fetch at all. A push needs my key: the prompt on a desktop, a forwarded agent on the server.
- No per-clone step: `git remote set-url --push` is not needed. A remote that has an explicit push URL
  is the exception: `pushInsteadOf` skips it and `insteadOf` still applies, so one spelled
  `git@github.com:` would go out over https and get a 403. Spell it `ssh://` or unset it.
- `ssh://` as the fetch URL means "use my key for this one": for a private repo no PAT covers, where
  https has nothing to answer with ("could not read Username").
- The credential part of the same file sends the repo path to the helper (the owner picks the PAT) and
  starts with an empty helper, which drops every helper set before it. It cannot drop one set later:
  in `~/.gitconfig`, which git reads after this file (the Mac has one), or appended below the include
  by `gh auth setup-git`. So helpers for GitHub live in `github.inc` only, and `fleet-check` fails on any other that could answer for it (one scoped to another host, like Heroku's, is left alone).
- On Omarchy `~/.config/git/config` is Omarchy's, and `git config --global` writes into it, so chezmoi
  only appends the include once (`modify_config`, as `modify_dot_bashrc` does for the shell).
- A `client` gets the push half only: no vault token there, so fetch is not rewritten and a
  `git@`/`ssh://` remote uses my key both ways.

Once per machine that was wired by hand before 2026-11-16, drop the old lines (harmless, but they hide
what answers), then check:

```sh
# the same three on ~/.gitconfig where that file exists (the Mac): add --file ~/.gitconfig
git config --global --remove-section credential.https://github.com        # absent: error, fine
git config --global --remove-section credential.https://gist.github.com   # absent: error, fine
git config --global --unset-all credential.helper                         # a generic helper, e.g. osxkeychain
chezmoi git -- config --unset remote.origin.pushurl                       # the old per-clone push URL
printf 'protocol=https\nhost=github.com\npath=basvanwesting/dotfiles.git\n\n' | git credential fill | grep -c '^password='   # check: 1
gh-agent repo view basvanwesting/dotfiles --json viewerPermission   # check: ADMIN
fleet-check
```

Rule for any future systemd unit that needs a secret (none does today; `herdr-server.service` has
none): `LoadCredential=` rather than `EnvironmentFile=`. `~/.claude/CLAUDE.md` carries the
day-to-day rules for agents.

## Server role (ser8)

`role = "server"` marks a headless, always-on machine reached over Tailscale/SSH. There is no GUI
1Password there, so `~/.1password/agent.sock` never exists. The server holds no SSH key either: git
goes over https with the scoped tokens from `agents`, and what needs a key (a push to this repo, a
login on a deploy host) runs in the login shell of a session opened with `ssh -A` from a desktop,
whose 1Password agent approves the use. The `.pub` selector files in `~/.ssh/config` pick the key
from that forwarded agent. Two limits: a herdr pane does not inherit the login's `SSH_AUTH_SOCK`, so
there is no agent in it; and while such a session is open every process of the user on ser8 can
reach the forwarded socket, within what 1Password already approved, so keep those sessions short.

### Bootstrap runbook

Omarchy ISO: Ctrl+C in the install form toggles disk encryption -- leave it OFF for an
unattended-boot server (a LUKS prompt blocks boot until someone types; see git log).
Reconsidered 2026-11-11 for gliff, kept OFF: gliff needs ssh + a running Hyprland, so it can't
answer the prompt. Premise: no sensitive data on ser8 (no personal data, no production exports);
its credentials are revocable, see "If ser8 is stolen". Reopen if data lands here. Rejected: TPM2
auto-unlock (only guards a pulled SSD), ssh unlock in the initramfs (dropbear; LAN-only, Tailscale
isn't up yet).
Hostname `ser8`. Unencrypted installs get no SDDM autologin; ser8 adds it (below), since gliff
(`gliff --headless basvanwesting@ser8`, decided 2026-11-11) needs a running Hyprland session of
this user and `gliff-server` attaches to one, it never starts one. `Relogin=true` restarts the
session if Hyprland exits; with BIOS Always On, a power cut ends back in a gliff-ready session.
Accepted: `stay-awake` also disables the idle lock, so the console session is never locked. With an
unencrypted disk physical access already meant full access; this only lowers the bar from booting
a USB stick to plugging in a monitor.

```sh
omarchy pkg add chezmoi ripgrep fd sd lazygit 1password-cli   # cli is not on a fresh install; `op-agent` needs it
omarchy install service tailscale && sudo tailscale set --ssh --advertise-tags=tag:server   # delete the old ser8 node in the admin console first; the tag: see Tailscale
omarchy toggle idle stay-awake     # always pass the mode: bare `toggle idle` flips it. Verify: omarchy toggle idle status
sudo loginctl enable-linger "$USER"
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl enable --now btrfs-scrub@-.timer   # monthly checksum verify; unclean power cuts are the norm here
printf '[Autologin]\nUser=%s\nSession=hyprland-uwsm\nRelogin=true\n' "$USER" | sudo tee /etc/sddm.conf.d/20-autologin.conf
sudo systemctl restart sddm                         # Hyprland now runs on seat0: pgrep -u "$USER" Hyprland
omarchy pkg add smartmontools                       # drive health: smartctl -a /dev/nvme0
install -d -m 700 ~/.config/op      # then place agent.token, 0600, from 1Password
chezmoi init https://github.com/basvanwesting/dotfiles.git      # fetch stays https: the server has no SSH key
# write ~/.config/chezmoi/chezmoi.toml: role = "server"
chezmoi apply
mise install                                                  # tools from ~/.config/mise/config.toml
systemctl --user enable --now herdr-server.service             # unit file comes from this repo
```

Manual, outside chezmoi:
- herdr: Omarchy stable lags upstream (0.8.2 vs 0.9.1 on 2026-09-21); install the same package from
  Omarchy's edge channel instead, see "herdr ahead of Omarchy stable" below. Never a hand-copied binary in
  `~/.local/bin`: Omarchy's herdr migration deletes it and re-adds the package on purpose.
- Tailscale: the tailnet policy and the `tag:server` tag, see [Tailscale](#tailscale). The tag also takes care of key expiry: a tagged node's key does not expire, so the headless box never drops off the tailnet waiting for a local re-auth.
- 1Password GUI off, only if the installer put it there (a fresh 3.x install had neither GUI nor cli):
  `rm ~/.config/autostart/com.onepassword.OnePassword.desktop`, `omarchy pkg drop 1password` (keeps 1password-cli).
- Git identity: the Omarchy first-run wizard already wrote it to `~/.config/git/config`; no `~/.gitconfig` needed.
- `chezmoi init` works against a pre-existing clone in `~/.local/share/chezmoi` (no repo arg, nothing re-cloned).
- BIOS (Beelink SER8, AMI Aptio): Del at boot, Advanced > AMD CBS > FCH Common Options > AC Power Loss Options > Always On, F4 to save. Not under any Power/Chipset menu. Test: unplug while off, replug, it should boot. Unplug the install USB.

### If ser8 is stolen

The disk is unencrypted (see above), so treat every credential on it as read. No device-side kill
switch (decided 2026-11-11): it only fires if the thief boots it online, and pulling the SSD
bypasses it. Revoke from another machine instead; ser8 has its own service account and no SSH
key, so this never touches the laptops. The specifics (which services, where to rotate each) are in a
private 1Password note, not here and not in `agents` (the vault being revoked):

1. 1Password: revoke ser8's service-account token.
2. GitHub: rotate the PATs in `agents`. Until then, and before any `dotup` or `git pull`
   anywhere, review commits pushed after the theft: every machine applies this repo, so a commit
   pushed with a GitHub token from `agents` would run on the laptops.
3. Rotate what ser8's token read after the theft, per the service accounts' activity log; rotate
   all of `agents` if the log can't tell. Items parked in `agents-disabled` need nothing.
4. Tailscale: remove the ser8 node (a tagged node's key does not expire, so it never drops off by itself).
5. Sign out ser8's sessions of any logged-in tools (agent subscriptions).
6. If personal data was on it after all (premise above broken): start the data breach procedure
   (GDPR: 72 hours to report).

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

macOS: standalone pkg from pkgs.tailscale.com (brew cask `tailscale-app` exists as an alternative, not used). The Mac runs no Tailscale SSH server (Linux-only feature): for SSH it connects out, nothing connects in.

### Policy: servers don't initiate (2026-11-16)

The tailnet policy lives in the admin console (Access controls), which keeps its own history. Its `ssh`
block, with `tag:server` owned by `autogroup:admin`:

```json
"ssh": [
  { "action": "accept", "src": ["autogroup:member"], "dst": ["autogroup:self"], "users": ["autogroup:nonroot"] },
  { "action": "accept", "src": ["autogroup:member"], "dst": ["tag:server"],     "users": ["autogroup:nonroot"] }
]
```

- `accept`, not the default `check`: `check` re-auths in a browser every 12h, a prompt that turns into a
  habit and that nothing unattended can answer. Inside the tailnet is trusted (global CLAUDE.md, Security).
- The edge is direction instead: ser8 is tagged `tag:server` (`sudo tailscale set --advertise-tags=tag:server`),
  so it is no longer one of my own devices and matches no `src`. The always-on box cannot open a session
  on a machine where I sit, next to the 1Password app and the browser. To go on from ser8, connect from
  the machine in front of you instead.
- A stolen, unlocked client still reaches every SSH-enabled node: that is covered by disk encryption,
  the screen lock and removing the node from the phone, not by this policy.
- Check: from ser8 `ssh ser9` ends in "tailnet policy does not permit you to SSH to this node"; from
  ser9 `ssh ser8` works.

## Syncthing (decided 2026-11-17)

`~/Sync` (documents, 21 GB) is one Syncthing folder, id `sync`, between the Mac and ser9; it replaces
Resilio Sync. Syncthing's config holds the device key, so it is machine state and not managed here:
only the package is declared (`~/.Brewfile`; the Omarchy install steps).

- Tailnet only: global and local discovery, relays and NAT traversal are off, and a device reaches
  the other by a fixed `tcp://<name>.<tailnet>.ts.net:22000`. Nothing is announced, to Syncthing's
  public servers or to the LAN. Cost: no sync while Tailscale is down. Usage and crash reporting are
  off for the same reason. Set these before the first start, or the device announces itself once.
- Every device listens on its own Tailscale address only (`tcp://<tailscale ip>:22000`) and has
  the others' addresses, so either side can dial and no pair depends on who starts. On the
  Mac the bind alone keeps the port off a Wi-Fi it joins (macOS only accepts a packet on the
  interface that owns the address). On Linux it does not: a LAN host that routes the address to
  the machine reaches the listener, and only ufw's default deny stops it. So no ufw rule may open
  22000, to any source or on any interface but `tailscale0`, and `fleet-check` exempts a
  tailnet-address listener only while that holds. Tailnet traffic gets in without a ufw rule (the Mac reached ser9 on 22000). A listener that cannot bind because
  Tailscale is not up yet is retried, seen at about one-minute intervals over two minutes, longer
  not measured. Rejected: a loopback-only listener on the desktops (dial-only), which passed the
  check unchanged but made every pair depend on one side. Not decided yet for ser8: whether its
  ufw needs a rule, and whether the user unit needs `loginctl enable-linger` (it runs only while
  the user has a session).
- No git repos inside `~/Sync`: Syncthing copies `.git` file by file, and work on two machines before
  a sync settles corrupts the repo. The old projects there are tarballs.
- `.stignore` is per machine and not synced; `(?d)` lets a folder that only holds ignored files be deleted.
- No file versioning yet; reopen when ser8, the always-on copy, joins.

A new device, before sharing the folder: get the tree there with rsync first (`rsync -a --delete
--exclude='.DS_Store' ~/Sync/ <host>:Sync/`), since Syncthing has no deletion history for a tree it
has not seen and would otherwise send stale files back.

```sh
syncthing generate --no-port-probing      # key and config, without starting
# in config.xml (`syncthing paths`): globalAnnounceEnabled, localAnnounceEnabled, relaysEnabled, natEnabled,
# crashReportingEnabled -> false; urAccepted -> -1; listenAddress -> tcp://<tailscale ip>:22000
printf '(?d).DS_Store\n(?d)._*\n' > ~/Sync/.stignore
brew services start syncthing             # Omarchy: systemctl --user enable --now syncthing.service
syncthing cli config devices add --device-id <other> --name <name> --addresses tcp://<name>.<tailnet>.ts.net:22000
syncthing cli config folders add --id sync --label Sync --path ~/Sync
syncthing cli config folders sync devices add --device-id <other>
```

Web UI: `http://127.0.0.1:8384` on each machine (ser9: over an ssh port forward).

## Fleet check

`fleet-check` (`~/.local/bin`, from this repo) compares the machine it runs on to what its role
expects and exits 1 on drift. The role in chezmoi is the declaration; the check asks the running
system whether it still holds, so a security review has something to look at. It reads state only
and prints no secret.

| Expectation | `desktop` | `server` | `client` |
|---|---|---|---|
| service-account token | yes | yes | no |
| any other token file in `~/.config/op` | none | none | none |
| private key files in `~/.ssh`, plain `gh` login, Fly login on disk | none | none | none |
| git over https uses the vault PATs; Claude `Read` deny rules | yes | yes | not checked |
| GitHub push goes over ssh; the dotfiles clone's push URL is `ssh://` | yes | yes | yes |
| GitHub fetch rewritten to https | yes | yes | no |
| credential helpers that can answer for GitHub, set outside `github.inc` (exempt: system config, which the reset drops, and a helper scoped to another host such as `git.heroku.com`) | none | none | none |
| 24h release cooldown in a fresh shell | yes | yes | yes |
| Tailscale SSH server / shields up (Linux) | on / down | on / down | off / up |
| tagged `tag:server` | no | yes | no |
| TCP listeners reachable from the LAN (Linux); one on the machine's tailnet address counts unless ufw is on, denies incoming by default and has no user rule that can open its port (any accepting rule not on `tailscale0` and not naming one other port) | none | shown, not judged | none |
| disk encryption | yes | no, by decision | yes |

Not looked at: UDP listeners, and on macOS listeners and the Tailscale SSH server.

Run it after changing a machine's setup, and on a machine that was off for a while. From another
machine: `ssh <host> fleet-check`. A new expectation is added here and in the script together, and
proven by breaking it once.

## Keybinding rules

- Prefix/leader keys are identical on both: herdr `ctrl+b` (stock), nvim leader `space`. `prefix+ctrl+b` (prefix twice) sends a literal `ctrl+b`, built in.
- Actions (split, close, resize, rename tab, workspaces by number) stay on herdr's stock prefix chords. Navigation also gets a prefix-free Alt chord, identical on both machines: `alt+left/right` tabs, `alt+1..9` switch tab, `ctrl+alt+arrows` focus pane, `alt+up/down` workspaces. Super stays with Hyprland; on macOS ghostty maps left Option to Alt (`macos-option-as-alt = left`).
- Ghostty is only the outer terminal: all of its own tab/split binds are unbound on both OSes so herdr owns those chords.
