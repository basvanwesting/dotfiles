# Shell-agnostic environment. Sourced by ~/.zshrc (macOS) and ~/.bashrc (Omarchy).
export EDITOR=nvim
export XDG_CONFIG_HOME="$HOME/.config"
export ERL_AFLAGS="-kernel shell_history enabled"
export CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# hyprctl from ssh shells and herdr panes (herdr-server starts outside Hyprland), so the
# headless ser8's windows can be maintained from there. Only fills in a missing or dead
# instance (Hyprland restarted via Relogin); a value Hyprland set itself is left alone.
# Newest live instance, as gliff-server picks. Shells older than a Hyprland restart: reload_all.
# `command ls`: Omarchy aliases ls to eza, and interactive bash expands aliases in sourced
# files. No glob: zsh errors on an unmatched one.
hypr_dir="${XDG_RUNTIME_DIR:-/run/user/$UID}/hypr"
if [ -d "$hypr_dir" ] && [ ! -S "$hypr_dir/${HYPRLAND_INSTANCE_SIGNATURE:-none}/.socket.sock" ]; then
  hypr_sig=$(command ls -t "$hypr_dir" | while read -r d; do
    if [ -S "$hypr_dir/$d/.socket.sock" ]; then echo "$d"; break; fi
  done)
  if [ -n "$hypr_sig" ]; then export HYPRLAND_INSTANCE_SIGNATURE="$hypr_sig"; fi
  unset hypr_sig
fi
unset hypr_dir
