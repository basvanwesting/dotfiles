# Dotfiles managed by chezmoi

## chezmoi.toml

```toml
[data]
have_nerd_font = true #boolean, use fancy fonts or not
personal = true       #boolean, whether machine is authenticated (e.g. github, copilot, docker)
remote = false        #boolean, connected by ssh terminal (i.e. auto-start terminal multiplexer in shell)
offline = false       #boolean, has access to internet (e.g. disable auto-installs, auto-updates, github)
```

## dependencies


```sh
brew install \
    alacritty \
    asdf \
    bat \
    bottom \
    chezmoi \
    fd \
    font-jetbrains-mono-nerd-font \
    fzf \
    git \
    make \
    neovim \
    nushell \
    pv \
    ripgrep \
    sd \
    starship \
    tokei \
    tree \
    yazi \
    zellij \
    zoxide

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
```
