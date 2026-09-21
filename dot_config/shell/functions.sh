# Shell-agnostic functions (POSIX sh). Sourced by ~/.zshrc (macOS) and ~/.bashrc (Omarchy).

e() {
  if [ $# -eq 0 ]; then
    nvim .
  else
    nvim "$@"
  fi
}

gtag() {
  git tag -a "$1" -m "$1"
}

bt() {
  if [ $# -eq 0 ]; then
    bundle exec rspec
  else
    bundle exec rspec "$@"
  fi
}

st() {
  if [ $# -eq 0 ]; then
    bundle exec spring rspec
  else
    bundle exec spring rspec "$@"
  fi
}

rmig() {
  bundle exec rake db:migrate RAILS_ENV="${1:-development}"
}

remig() {
  bundle exec rake db:migrate:redo RAILS_ENV="${1:-development}"
}

unmig() {
  bundle exec rake db:rollback RAILS_ENV="${1:-development}"
}

# Reload every idle shell pane in herdr (skips agents and panes running a program).
# reload_all [machine]  -> reload_all ser8 acts on that saved machine's server.
reload_all() {
  h="herdr${1:+ --machine $1}"
  $h pane list | python3 -c "import json,sys;[print(p['pane_id']) for p in json.load(sys.stdin)['result']['panes'] if not p.get('agent')]" |
  while read -r id; do
    fg=$($h pane process-info --pane "$id" | python3 -c "import json,sys;p=json.load(sys.stdin)['result']['process_info']['foreground_processes'];print(p[0]['argv0'] if p else '')")
    case "$fg" in
      zsh|bash) $h pane run "$id" reload >/dev/null && echo "reloaded $id" ;;
      *) echo "skipped  $id (running: ${fg:-?})" ;;
    esac
  done
  unset h fg
}
