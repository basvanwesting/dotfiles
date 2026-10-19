# Sourced by Livebook Desktop at boot. A Dock-launched app gets launchd's bare PATH,
# so Mix.install deps that build NIFs (torchx needs cmake) can't find Homebrew tools.
eval "$(/opt/homebrew/bin/brew shellenv)"
