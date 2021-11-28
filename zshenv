export PATH="$HOME/.local/bin:$PATH"

# _pid=$(pgrep blackd)
# if [ -z "$_pid" ]
# then
#     nohup blackd > /dev/null 2>&1 &
# fi

_pid=$(pgrep sabnzb)
if [ -z "$_pid" ]
then
    sudo /etc/init.d/sabnzbdplus start > /dev/null 2>&1
fi
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
source $(pyenv root)/completions/pyenv.zsh
eval "$(direnv hook zsh)"
/usr/bin/keychain --nogui $HOME/.ssh/id_ed25519
source $HOME/.keychain/Gwen-sh
