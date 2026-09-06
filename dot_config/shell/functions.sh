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
