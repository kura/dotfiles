alias dist-upgrade='sudo apt update -y && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y'

reload() {
  exec "$SHELL"
}

git() {
  case $@ in
    undo|sy|sync|sw|switch|pub|publish|unp|unpublish|rs|resync|branches)
      cmd='legit'
      ;;
    *)
      cmd='hub'
      ;;
  esac
  command "$cmd" "$@"
}

apt() {
  case $@ in
    install|dist-upgrade|update)
      cmd='apt-fast'
      ;;
    *)
      cmd='/usr/bin/apt'
      ;;
  esac
  command "$cmd" "$@"
}

function pgp-search() {
  if [ $# -ne 1 ]
  then
    echo "Usage: pgp-search TERM"
  else
    gpg --search-keys --keyserver pgp.mit.edu $1
  fi
}

pip-upgrade() {
  venvs=`find ~/.local/venvs -maxdepth 1 -mindepth 1 -type d | sort`
  for env in $venvs
  do
    echo $env
    echo "=========="
    $env/bin/pip install -U pip
    $env/bin/pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | sort | xargs $env/bin/pip install -U
    echo
  done
  venvs=`find ~/.virtualenvs -maxdepth 1 -mindepth 1 -type d | sort `
  for env in $venvs
  do
    echo $env
    echo "=========="
    $env/bin/pip install -U pip
    $env/bin/pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | sort | xargs $env/bin/pip install -U
    echo
  done
}

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias python='python3.6'
alias virtualenv='virtualenv-3.6'
alias pip='pip3.6'
alias sl='sl -eal'
alias wo='workon'
alias da='deactivate'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

_virtualenvs () {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "`virtualenvwrapper_show_workon_options`" -- ${cur}) )
}
complete -o default -o nospace -F _virtualenvs wo