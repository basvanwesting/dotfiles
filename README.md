# Dotfiles managed by chezmoi

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
    neovim \
    nushell \
    pv \
    ripgrep \
    starship \
    tokei \
    tree \
    yazi \
    zellij \
    zoxide

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
