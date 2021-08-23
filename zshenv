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
