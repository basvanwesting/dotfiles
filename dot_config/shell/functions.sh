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

# Reload every idle shell pane in herdr; panes running a program (incl. agents) are skipped.
# reload_all [machine]  -> reload_all ser8 acts on that saved machine's server.
# herdr only prints JSON; grep/cut keep this free of jq or python.
reload_all() {
  _m=$1
  _herdr() { if [ -n "$_m" ]; then herdr --machine "$_m" "$@"; else herdr "$@"; fi; }
  for _id in $(_herdr pane list | grep -o '"pane_id":"[^"]*"' | cut -d'"' -f4); do
    _fg=$(_herdr pane process-info --pane "$_id" | grep -o '"argv0":"[^"]*"' | head -1 | cut -d'"' -f4)
    case "$_fg" in
      zsh|bash) _herdr pane run "$_id" reload >/dev/null && echo "reloaded $_id" ;;
      *) echo "skipped  $_id (running: ${_fg:-?})" ;;
    esac
  done
  unset -f _herdr; unset _m _id _fg
}
