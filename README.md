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

sh -c "$(curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs)"
cargo install nu_plugin_polars
RUN nu -c "plugin add ~/.cargo/bin/nu_plugin_polars"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
