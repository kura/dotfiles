alias dist-upgrade='sudo apt update -y && sudo apt list --upgradable && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo apt autoclean -y'

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
  orig_pwd=`pwd`
  venvs=`find ~/.local/venvs -maxdepth 1 -mindepth 1 -type d | sort`
  for env in $venvs
  do
    echo -e "\e[1;4m${env}\e[0m"
    cd $env
    bin/pip install -U pip | colout 'up\-to\-date\:\ (.*)\ in' purple | colout 'in\ (.*)' blue | colout 'up-to-date' green | colout 'Collecting\ (.*)' purple | colout 'packages\:\ (.*)' purple | colout 'installation\:\ (.*)' purple | colout 'Uninstalling\ (.*)' purple | colout '(Successfully\ uninstalled\ .*)' green | colout '(Successfully\ installed\ .*)' green | colout '(Downloading\ .*)' orange | colout '(Using\ cached\ .*)' orange
    bin/pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | sort | xargs bin/pip install -U | colout 'up\-to\-date\:\ (.*)\ in' purple | colout 'in\ (.*)' blue | colout 'up-to-date' green | colout 'Collecting\ (.*)' purple | colout 'packages\:\ (.*)' purple | colout 'installation\:\ (.*)' purple | colout 'Uninstalling\ (.*)' purple | colout '(Successfully\ uninstalled\ .*)' green | colout '(Successfully\ installed\ .*)' green | colout '(Downloading\ .*)' orange | colout '(Using\ cached\ .*)' orange
    cd $orig_pwd
    echo
  done
  venvs=`find ~/.virtualenvs -maxdepth 1 -mindepth 1 -type d | sort `
  for env in $venvs
  do
    echo -e "\e[1;4m${env}\e[0m"
    cd $env
    bin/pip install -U pip | colout 'up\-to\-date\:\ (.*)\ in' purple | colout 'in\ (.*)' blue | colout 'up-to-date' green | colout 'Collecting\ (.*)' purple | colout 'packages\:\ (.*)' purple | colout 'installation\:\ (.*)' purple | colout 'Uninstalling\ (.*)' purple | colout '(Successfully\ uninstalled\ .*)' green | colout '(Successfully\ installed\ .*)' green | colout '(Downloading\ .*)' orange | colout '(Using\ cached\ .*)' orange
    bin/pip freeze --local | grep -v '^\-e' | cut -d = -f 1 | sort | xargs bin/pip install -U | colout 'up\-to\-date\:\ (.*)\ in' purple | colout 'in\ (.*)' blue | colout 'up-to-date' green | colout 'Collecting\ (.*)' purple | colout 'packages\:\ (.*)' purple | colout 'installation\:\ (.*)' purple | colout 'Uninstalling\ (.*)' purple | colout '(Successfully\ uninstalled\ .*)' green | colout '(Successfully\ installed\ .*)' green | colout '(Downloading\ .*)' orange | colout '(Using\ cached\ .*)' orange
    cd $orig_pwd
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

alias ls='colorls -l'
alias ack='pt'
