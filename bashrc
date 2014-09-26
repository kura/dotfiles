# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PATH=$PATH:~/go/bin:~/.local/bin

HISTCONTROL=ignoredups:ignorespace
shopt -s histappend
PROMPT_COMMAND='history -a'
HISTSIZE=100000
HISTFILESIZE=100000
shopt -s checkwinsize
shopt -s cmdhist
shopt -s cdspell

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ `id -u` = 0 ]; then
    HOST_COLOUR="01;31m"
    PATH_COLOUR="01;31m"
else
    HOST_COLOUR="01;32m"
    PATH_COLOUR="01;34m"
fi

function _git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1  /'
}

function git_branch {
    if [[ "git branch --no-color 2> /dev/null" != 'false' ]]
    then
        echo -e "\033[01;36m$(_git_branch)\033[00m"
    fi
}

function git_untracked {
    if git rev-parse --is-inside-work-tree &> /dev/null
    then
        if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
        then
            echo ""
        else
            echo -e "\033[01;31m⚑ \033[00m"
        fi
    fi
}

function git_needs_commit {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
        (( $? && $? != 128 )) && echo -e "\033[01;32m⚑ \033[00m"
    fi
}

function git_tracked {
    if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
    then
        git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo -e "\033[01;34m⚑ \033[00m"
    fi
}

function _short_pwd {
    echo $PWD | sed "s:${HOME}:~:" | sed "s:/\(.\)[^/]*:/\1:g" | sed "s:/[^/]*$:/$(basename $PWD):"
}

function short_pwd {
    echo -e "\033[$PATH_COLOUR$(_short_pwd)\033[00m"
}

function _hostname {
    echo "${HOSTNAME}" | cut -d "." -f1
}

function hostname {
    echo -e "\033[$HOST_COLOUR$(_hostname)\033[00m"
}

function exit_code {
    if [[ $? == 0 ]]
    then
        echo -e "$? \033[01;32m✓\033[00m"
    else
        echo -e "$? \033[01;31m✗\033[00m"
    fi
}

PS1='$(exit_code) $(hostname):$(short_pwd) $(git_branch)$(git_untracked)$(git_tracked)$(git_needs_commit)⚡ '

unset color_prompt force_color_prompt

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color'
fi

alias less='less -R'
alias git='hub'
alias dist-upgrade='sudo apt-get update -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y && sudo apt-get autoclean -y'
alias pip-upgrade='pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs pip install -U'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
export WORKON_HOME=/home/kura/.virtualenvs
export VIRTUALENVWRAPPER_LOG_DIR="$WORKON_HOME"
export VIRTUALENVWRAPPER_HOOK_DIR="$WORKON_HOME"
alias workoff='deactivate'
source /usr/local/bin/virtualenvwrapper.sh
export PYTHONSTARTUP=~/.pythonrc
export PYTHONSTARTUP=~/.pystartup
source <(npm completion)

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end

function pgp-search() {
  if [ $# -ne 1 ]
  then
    echo "Usage: gpg-search TERM"
  else
    gpg --search-keys --keyserver keyserver.tangentlabs.co.uk $1
  fi
}

function colourless() {
    if [ $# -ne 1 ]
    then
        # assume pipe
        while read -r data
        do
            sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"
        done
    else
        sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" $1
    fi
}

function mkvirtualenv() {
  if [[ $# -ne 2 ]]
  then
    echo "Usage: mkvirtualenv PYTHON_VER NAME"
  else
    PY_VER=$1
    if [[ $PY_VER == 'pypy' || $PY_VER == 'pypy3' ]]
    then
      PY_BIN=/opt/$PY_VER/bin/pypy
    else
      PY_BIN=/usr/bin/python$PY_VER
    fi
    NAME=$2
    virtualenv -p $PY_BIN /home/kura/.virtualenvs/$NAME-$PY_VER
    workon $NAME-$PY_VER
  fi
}

function _mkvirtualenv() {
    cur="${COMP_WORDS[COMP_CWORD]}"
    py="2.6 2.7 3.3 3.4 pypy pypy3"
    COMPREPLY=($(compgen -W "${py}" -- ${cur}))
}

complete -F _mkvirtualenv mkvirtualenv

function portforward() {
  if [[ $# -ne 2 ]]
  then
    echo "Usage: portforward HOST PORT";
  else
    HOST=$1
    REMOTE_PORT=$2
    # Pick a random port and check it is free
    LOCAL_PORT=$((RANDOM+1000))
    if ! [[ `lsof -i :$LOCAL_PORT | grep COMMAND` ]]
    then
      # Port is free - woop!
      echo "Forwarding to port $REMOTE_PORT on $HOST from http://localhost:$LOCAL_PORT"
      ssh -f -L $LOCAL_PORT:localhost:$REMOTE_PORT $HOST -N 2> /dev/null
    else
      # Recursion ftw
      portforward $HOST $REMOTE_PORT
    fi
  fi
}
 
# Used for autocompletion
function _portforward() {
  cur="${COMP_WORDS[COMP_CWORD]}"
  # COMP_CWORD-1 = portforward, i.e. the name of this function, so autocomplete SSH host
  if [[ ${COMP_WORDS[COMP_CWORD-1]} == "portforward" ]]
  then
    # the sed call is there to combat people like me who have "grep --color=always" on by default
    hosts=$(grep "Host " ~/.ssh/config | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | grep -v "#" | grep -v "*" | awk '{print $2}')
    COMPREPLY=($(compgen -W "${hosts}" -- ${cur}))
  else
    # otherwise assume on second arg, so autocomplete service name
    ports="22 80 2222 3306 5432 8080 11211 55672 15672"
    COMPREPLY=($(compgen -W "${ports}" -- ${cur}))
  fi
  return 0
}
 
complete -F _portforward portforward

__ltrim_colon_completions() {
    # If word-to-complete contains a colon,
    # and bash-version < 4,
    # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
    if [[
        "$1" == *:* && (
            ${BASH_VERSINFO[0]} -lt 4 ||
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*)
        )
    ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%${1##*:}}
        local i=${#COMPREPLY[*]}
        while [ $((--i)) -ge 0 ]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
        done
    fi
} # __ltrim_colon_completions()

_nosetests()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    if [[
            ${BASH_VERSINFO[0]} -lt 4 ||
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*)
    ]]; then
        local i=$COMP_CWORD
        while [ $i -ge 0 ]; do
            [ "${COMP_WORDS[$((i--))]}" == ":" ] && break
        done
        if [ $i -gt 0 ]; then
            cur=$(printf "%s" ${COMP_WORDS[@]:$i})
        fi
    fi
    COMPREPLY=(`nosecomplete ${cur} 2>/dev/null`)
    __ltrim_colon_completions "$cur"
}

complete -o nospace -F _nosetests nosetests

source /usr/local/hop/hop.bash

pipsi-upgrade() {
    for i in `find ~/.local/venvs/ -maxdepth 1 -type d`
    do
        if [ $i != "/home/kura/.local/venvs" ]
        then
            old_pwd=$PWD
            cd ${i}bin/
            ./pip freeze --local | grep -v '^\-e' | cut -d = -f 1  | xargs ./pip install -U
            cd $old_pwd
        fi
    done
}
