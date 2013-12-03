PATH=$PATH:/usr/local/sbin

BLACK="\[\033[0;30m\]"
BLACKBOLD="\[\033[1;30m\]"
RED="\[\033[0;31m\]"
REDBOLD="\[\033[1;31m\]"
GREEN="\[\033[0;32m\]"
GREENBOLD="\[\033[1;32m\]"
YELLOW="\[\033[0;33m\]"
YELLOWBOLD="\[\033[1;33m\]"
BLUE="\[\033[0;34m\]"
BLUEBOLD="\[\033[1;34m\]"
PURPLE="\[\033[0;35m\]"
PURPLEBOLD="\[\033[1;35m\]"
CYAN="\[\033[0;36m\]"
CYANBOLD="\[\033[1;36m\]"
WHITE="\[\033[0;37m\]"
WHITEBOLD="\[\033[1;37m\]"

ENDSTYLE="\[\033[0m\]"
NORMAL="\[\033[0;39m\]"

UND='\[\e[4m\]'
NOUND='\[\e[0m\]'

# Fun
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# XCode
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/Developer/SDKs/MacOSX10.6.sdk/usr/include
export LIBRARY_PATH=$LIBRARY_PATH:/Developer/SDKs/MacOSX10.6.sdk/usr/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/Developer/SDKs/MacOSX10.7.sdk/usr/include
export LIBRARY_PATH=$LIBRARY_PATH:/Developer/SDKs/MacOSX10.7.sdk/usr/lib

# Java
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home

# EC2
export EC2_HOME=/usr/local/ec2
export EC2_PRIVATE_KEY=~/.ec2/pk-Z7A6FSWQJ65GA7HZPTYM5BVTNMZZCJH3.pem
export EC2_CERT=~/.ec2/cert-Z7A6FSWQJ65GA7HZPTYM5BVTNMZZCJH3.pem

# Python
export PYTHONSTARTUP=~/.python
export PYTHONPATH=/gc/gclib/python:$PYTHONPATH
export DJANGO_SETTINGS_MODULE=gcapi.settings

export WORKON_HOME=/gc/envs

if [ -f $HOME/.code ]
then
    source $HOME/.code
fi

source /usr/local/bin/virtualenvwrapper.sh
if [ -z "$VIRTUAL_ENV" ]
then
    echo "workon local"
    workon local
fi

export CODE=${CODE-"$HOME/code"}
export REPO_PREFIX=${REPO_PREFIX-"gc"}

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
    if [ -d ${CODE}/${REPO_PREFIX}$1 ]
    then
        cd ${CODE}/${REPO_PREFIX}$1
    else
        cd ${CODE}/$1
    fi
}

function git-get-branch() { git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
function fancy-git-branch() { git-get-branch | sed -e 's/\(.*\)/ → \1/'; }
function git-current-repo() { git config --get remote.origin.url | sed -e 's/\.git//' -e "s/.*\/\(.*\)/\1/" -e 's/^gc//'; }
function current-virtualenv() { echo $VIRTUAL_ENV | sed -e "s/.*\/\(.*\)/\1/"; }
function fancy-virtualenv() { echo `current-virtualenv` | sed -e "s/\([^\s]+\)/(\1)/"; }

function find-git-root() {
 A=.
 while ! [ -d $A/.git ]; do
  A="$A/.."
 done
 echo $A
}

export SLUGX="[ ,\.]"
function slug() { echo $@ | sed -e "s/${SLUGX}${SLUGX}*/_/g" -e "s/^_*\(.*\)_*$/\1/" | tr '[:upper:]' '[:lower:]'; }

function git-pull-request() {
    hub pull-request -h gamechanger:$(git-get-branch)
}

function git-pickaxe() {
    m="$@"
    echo "git log -S\"$m\"";
    git log -S"$m";
}

function git-delete-branch() {
    git branch -D $1 &&
    git push origin :$1;
}

function git-checkout-topic() {
    git checkout -b ks_`slug $@`;
}

function git-unsluggify-branch() {
    git-get-branch | sed -e 's/^ks_\(.*\)/\1/' -e 's/_/ /g';
}

function git-easy-pull-request() {
    git-checkout-topic $@ &&
    local message=$@;
    git add -p &&
    git commit -m "$message" &&
    git push origin `git-get-branch` -u &&
    git-pull-request
}

function git-drop-current-branch() {
    b=`git-get-branch`
    if [ "$b" = "master" ]
    then
        echo "you can't drop the master branch, you, I'm saving you from yourself"
    else
        echo "git checkout master" &&
        git checkout master &&
        echo "git-delete-branch $b" &&
        git-delete-branch $b
    fi
}

function stage-gc { pushd ${CODE}/${REPO_PREFIX}systems/script && python stage.py $@; popd; }
function deploy-gc { pushd ${CODE}/${REPO_PREFIX}systems/script && python deploy.py $@; popd; }

function ssh-tunnel {
    echo "connecting local port $1 to port $3 on $2" &&
    ssh -f ${2} -L ${1}:localhost:${3} -N;
}

function querysh { ssh -t batch1-prod 'sudo -u gcapp bash -c "source /gc/envs/prod/bin/activate; /gc/gcsystems/script/querysh prod"'; }

function gcssh {
    knife ssh -c /gc/gcchef/.chef/knife.rb -a name -x ubuntu -i /gc/gcchef/.chef/gc-apps.pem "$1" "$2";
}

function enfeature() {
    echo "db.features.update({_id: '$1'}, {\$set: {status: 'on'}})"
    mongo frontend --eval "db.features.update({_id: '$1'}, {\$set: {status: 'on'}})"
}

function disfeature() {
    echo "db.features.update({_id: '$1'}, {\$set: {status: 'on'}})"
    mongo frontend --eval "db.features.update({_id: '$1'}, {\$set: {status: 'off'}})"
}

function lsfeatures() {
    if [ -z "$1" ]
    then
        query='{}'
    else
        query="{status: '$1'}"
    fi
    echo "db.features.find($query).forEach(function(f){print('\"'+f._id+'\"' + '\tis\t' + f.status + '\tfor\t' + f.availability);})"
    mongo frontend --eval "db.features.find($query).forEach(function(f){print('\"'+f._id+'\"' + '\tis\t' + f.status + '\tfor\t' + f.availability);})"
}

alias bounce="sudo apachectl restart"
alias bing="touch ./apache/local.wsgi"
alias stage="stage-gc"
alias deploy="deploy-gc"
alias stageme="stage-gc \$(git-get-branch)"

# Git shortcuts
alias push="git push origin \$(git-get-branch)"
alias pull="git pull --rebase"
alias rebase="git rebase"
alias co="git checkout"
alias axe="git-pickaxe"
alias gsync="git pull --rebase && git push origin \$(git-get-branch)"
alias gc="git commit"
alias ga="git add"
alias gs="git status"
alias gd="git diff"
alias show="git show"
alias stash="git stash"

# PR / branch management
alias g0="gco master"
alias start="git-checkout-topic"
alias stop="git-drop-current-branch"
alias drop="git-delete-branch"
alias ezpr="git-easy-pull-request"
alias gpr="git-pull-request"
alias yolo="sudo"
alias please="sudo"

# Heroku
alias save="git push gh \$(git-get-branch)"
alias roll="git push origin \$(git-get-branch)"

function new_prompt {
    export PS1="${CYANBOLD}$(hostname)\n${RED}${UND}$(git-current-repo)${ENDSTYLE}${YELLOW}$(fancy-git-branch)${NORMAL}|\W $ "
}

function prompt {
    char="♖"
    export PS1="${CYANBOLD}@$(hostname)\n${RED}${UND}$(git-current-repo)${ENDSTYLE}${YELLOW}$(fancy-git-branch)${NORMAL}|${PURPLE}\W${NORMAL} ${char}  "
}

prompt

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

if [ -d ~/.rvm ]
then
    source ~/.rvm/scripts/rvm
    rvm use 1.9.3@gcmobile --create
else
    echo -e '\[\e[4m\]no RVM installed\[\e[0m\]'
fi
