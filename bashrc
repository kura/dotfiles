export PATH=~/.local/bin:$PATH

# If not running interactively, don't do anything
case $- in
  *i*) ;;
  *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

# if [ `id -u` = 0 ]
# then
#   PATH_COLOUR="01;31m"
# else
#   PATH_COLOUR="01;34m"
# fi
# 
# function git_branch {
#   if [[ $(git branch --no-color 2> /dev/null) ]]
#   then
#     gb=`git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\(\1\) /'`
#     echo -e "${gb}"
#   fi
# }
# 
# function git_untracked {
#   if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == true ]]
#   then
#     if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
#     then
#       echo ""
#     else
#       echo -e "* "
#     fi
#   fi
# }
# 
# function git_needs_commit {
#   if [[ $(git rev-parse --is-inside-work-tree &> /dev/null) != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
#   then
#     git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
#     (( $? && $? != 128 )) && echo -e "* "
#   fi
# }
# 
# function git_staged {
#   if [[ $(git rev-parse --is-inside-work-tree &> /dev/null) != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
#   then
#     git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo -e "* "
#   fi
# }
# 
# ci-status() {
#   status=$(git ci-status 2> /dev/null)
#   case "$status" in
#     success)
#       echo -e "\033[01;32m✔\033[00m "
#       ;;
#     failure)
#       echo -e "\033[01;31m✘\033[00m "
#       ;;
#     *)
#       echo -e ""
#       ;;
#   esac
# }
# 
# function short_pwd {
#   echo $PWD | sed "s:${HOME}:~:" | sed "s:/\(.\)[^/]*:/\1:g" | sed "s:/[^/]*$:/$(basename $PWD):"
# }
# 
# function virtualenv_info {
#   if [[ -n "$VIRTUAL_ENV" ]]
#   then
#     venv="${VIRTUAL_ENV##*/}"
#   else
#     venv=''
#   fi
#   [[ -n "$venv" ]] && echo "($venv) "
# }

export VIRTUAL_ENV_DISABLE_PROMPT=1

#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# PS1='\[\033[01;36m\]$(virtualenv_info)\[\033[00m\]\[\033[$PATH_COLOUR\]$(short_pwd)\[\033[00m\] \[\033[01;36m\]$(git_branch)\[\033[00m\]\[\033[01;31m\]$(git_untracked)\[\033[00m\]\[\033[01;34m\]$(git_staged)\[\033[00m\]\[\033[01;32m\]$(git_needs_commit)\[\033[00m\]$(ci-status)\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
  xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
  *)
    ;;
esac

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
# alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3.6
export WORKON_HOME=/home/kura/.virtualenvs
export VIRTUALENVWRAPPER_LOG_DIR="$WORKON_HOME"
export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
source /usr/local/bin/virtualenvwrapper.sh

_pip_completion()
{
  COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                 COMP_CWORD=$COMP_CWORD \
                 PIP_AUTO_COMPLETE=1 $1 ) )
}

complete -o default -F _pip_completion pip

_knock()
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=$(grep '^Host' ~/.ssh/config | awk '{print $2}')

  COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
  return 0
}

complete -F _knock knock

ssh() {
  if [ $# -ne 1 ]
  then
    echo "Usage: ssh [user@]host"
    return
  fi
  # Knock file
  # 
  # Format -
  #
  # SERVER1="PORT1 PORT2 ..."
  # SERVER2="PORT1 PORT2 ..."
  #
  # web="123 456 789 1011"
  # db="234 567 8910 1112"
  #
  source ~/.ssh/knock
  name=`echo $1 | cut -d"." -f1`
  if [ -n "${!name}" ]
  then
    for p in ${!name}
    do
      /usr/bin/knock $1 $p
    done
  fi
  /usr/bin/mosh --ssh="ssh -vv" $1
}

_ssh() 
{
  local cur prev opts
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  opts=$(grep '^Host' ~/.ssh/config | awk '{print $2}')

  COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
  return 0
}
complete -F _ssh ssh

if ! test -f /tmp/.ssh-agent-thing
then
  killall ssh-agent &>/dev/null
  ssh-agent -s | grep -v 'echo Agent' > /tmp/.ssh-agent-thing
  . /tmp/.ssh-agent-thing
else
  . /tmp/.ssh-agent-thing
fi

# added by travis gem
[ -f /home/kura/.travis/travis.sh ] && source /home/kura/.travis/travis.sh


export THEME=$HOME/.bash/themes/agnoster-bash/agnoster.bash
if [[ -f $THEME ]]; then
    export DEFAULT_USER=""
    source $THEME
fi
