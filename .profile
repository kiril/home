export WORKON_HOME=/gc/env
source /usr/local/bin/virtualenvwrapper.sh

export CODE="$HOME/code"

function end-of-path { echo $1 | sed -e "s/.*\/\(.*\)/\1/"; }
function pwd-name() { end-of-path `pwd`; }

function in-list() {
    local search="$1"
    shift
    local list=("$@")
    for file in "${list[@]}" ; do
        [[ "$file" == "$search" ]] && return 0
    done
    return 1
}

function code() {
    cd $CODE/$1;
    local here=$(pwd-name);
    local envs=`lsvirtualenv`
    if in-list $here $envs
    then
        workon $here
    fi
}

function git-get-branch() { git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
function fancy-git-branch() { git-get-branch | sed -e 's/\(.*\)/ → \1/'; }
function git-current-repo() { git config --get remote.origin.url | sed -e "s/.*\/\(.*\)\.git/\1/" -e 's/^gc//'; }
function current-virtualenv() { echo $VIRTUAL_ENV | sed -e "s/.*\/\(.*\)/\1/"; }
function fancy-virtualenv() { echo `current-virtualenv` | sed -e "s/\([^\s]+\)/(\1)/"; }

function find-git-root() {
 A=.
 while ! [ -d $A/.git ]; do
  A="$A/.."
 done
 echo $A
}

function git-pull-request() { hub pull-request "$1" -h gamechanger:$(git-get-branch) | xargs open; }
function git-pickaxe() { git log -S"$1"; }

alias api="code gcapi"
alias web="code gcweb"
alias api2="code gcapi2"
alias sys="code gcsystems"
alias lib="code gclib"
alias conf="code gcconfig"

alias gc="git commit"
alias ga="git add"
alias gs="git status"
alias gd="git diff"
alias gow="git show"
alias gash="git stash"
alias grb="git rebase"
alias gsync="git pull --rebase && git push origin \$(git-get-branch)"
alias gpr="git-pull-request"
alias gpx="git-pickaxe"
alias gpush="git push origin \$(git-get-branch)"
alias gpull="git pull --rebase"
alias gco="git checkout"
alias gb="git checkout -b"
alias g0="gco master"

#export PS1='$(fancy-virtualenv)\[\e[1;31m\]$(git-current-repo)\[\e[1;33m\]$(fancy-git-branch)\[\e[0;39m\]|\[\e[0;39m\]\W $ '
export PS1='\[\e[1;31m\]$(git-current-repo)\[\e[1;33m\]$(fancy-git-branch)\[\e[0;39m\]|\[\e[0;39m\]\W $ '
