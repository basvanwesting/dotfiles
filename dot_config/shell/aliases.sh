# Shell-agnostic aliases. Sourced by ~/.zshrc (macOS) and ~/.bashrc (Omarchy).

# Git
alias g='git status'
alias gdc='git diff --cached'
alias gr="git log --graph --pretty=format:'%C(yellow)%h %ad %an%Cgreen%d %Creset%s' --date=short"
alias gt="git log --graph --simplify-by-decoration --pretty=format:'%d' --date=short --all"
alias gg='lazygit'

# Processes
alias psp='ps aux | egrep -v "Evernote|Dropbox" | egrep -i --color "ruby|rails|rake|spring|puma|unicorn|delayed|vbox|python|neovim|phantomjs|beam|erlang|elixir|vim|coc"'

# Rails: bundle exec rspec
alias btmo='git ls-files --modified --others spec | grep _spec.rb | tee /dev/tty | xargs bundle exec rspec'
alias btt="git status spec | grep -v 'deleted: ' | grep -o -E '\S+(_spec.rb|\/)$' | tee /dev/tty | xargs bundle exec rspec"
alias bth='git show --name-only --no-notes --oneline HEAD | grep _spec.rb | tee /dev/tty | xargs bundle exec rspec'
alias btf="fzf -m --bind enter:clear-selection+select-all+accept --query '_spec.rb$ ' | tee /dev/tty | xargs bundle exec rspec"
alias btof='bundle exec rspec --only-failures'

# Rails: bundle exec spring rspec
alias ss='bundle exec spring stop'
alias stmo='git ls-files --modified --others spec | grep _spec.rb | tee /dev/tty | xargs bundle exec spring rspec'
alias stt="git status spec | grep -v 'deleted: ' | grep -o -E '\S+(_spec.rb|\/)$' | tee /dev/tty | xargs bundle exec spring rspec"
alias sth='git show --name-only --no-notes --oneline HEAD | grep _spec.rb | tee /dev/tty | xargs bundle exec spring rspec'
alias stf="fzf -m --bind enter:clear-selection+select-all+accept --query '_spec.rb$ ' | tee /dev/tty | xargs bundle exec spring rspec"
alias stof='bundle exec spring rspec --only-failures'

alias wiki='e ~/bin/wiki'

# Machine-local, unmanaged (client project shortcuts etc.): not in the public repo.
[ -r "$HOME/.config/shell/local.sh" ] && . "$HOME/.config/shell/local.sh"
