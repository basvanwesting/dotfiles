# Sourced by Livebook Desktop at boot. A Dock-launched app gets launchd's bare PATH,
# so Mix.install deps that build NIFs (torchx needs cmake) can't find Homebrew tools.
eval "$(/opt/homebrew/bin/brew shellenv)"

# Start the file picker in the notebooks repo, on machines that have it checked out.
if [ -d "$HOME/workspace/livebooks" ]; then
  export LIVEBOOK_HOME="$HOME/workspace/livebooks"
fi
