export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
source $(pyenv root)/completions/pyenv.zsh
eval "$(direnv hook zsh)"

export FLYCTL_INSTALL="/home/kura/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

/usr/bin/keychain --nogui $HOME/.ssh/id_ed25519
source $HOME/.keychain/Gwen-sh
