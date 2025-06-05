# Dotfiles managed by chezmoi

## ~/.config/chezmoi/chezmoi.toml

```toml
[data]
have_nerd_font = true #boolean, use fancy fonts or not
personal = true       #boolean, whether machine is authenticated (e.g. github, copilot, docker)
remote = false        #boolean, connected by ssh terminal (i.e. auto-start terminal multiplexer in shell)
offline = false       #boolean, has access to internet (e.g. disable auto-installs, auto-updates, github)
```

## Install

```sh
brew install \
    alacritty \
    chezmoi \
    font-jetbrains-mono-nerd-font \
    fzf \
    git \
    make \
    neovim \
    ripgrep \
    starship \
    zellij

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

chezmoi init https://github.com/basvanwesting/dotfiles.git
cat << EOF > ~/.config/chezmoi/chezmoi.toml
[git]
autoCommit = true
autoPush = true

[data]
have_nerd_font = true
personal = true
remote = false
offline = false
EOF
chezmoi apply
```

## Additional installs

```sh
brew install \
    asdf \
    bat \
    bottom \
    fd \
    nushell \
    pv \
    sd \
    tokei \
    tree \
    yazi \
    zoxide

asdf plugin add bazel
asdf plugin add elixir
asdf plugin add elixir-ls
asdf plugin add erlang
asdf plugin add lua
asdf plugin add lua-language-server
asdf plugin add nodejs
asdf plugin add perl
asdf plugin add python
asdf plugin add ruby
asdf plugin add stylua
asdf plugin add yarn

sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
```
