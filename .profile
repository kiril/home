PATH=$PATH:/usr/local/sbin

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
export PYTHONPATH=/gc/gclib/python
export DJANGO_SETTINGS_MODULE=gcapi.settings

export WORKON_HOME=/gc/envs

if [ -f $HOME/.code ]
then
    source $HOME/.code
fi

source /usr/local/bin/virtualenvwrapper.sh

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
    cd ${CODE}/${REPO_PREFIX}$1;
#    local here=$(pwd-name);
#    local envs=`lsvirtualenv`
#    if in-list $here $envs
#    then
#        workon $here
#    fi
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
    local message=$@
    hub pull-request "$message" -h gamechanger:$(git-get-branch) | xargs open
}
function git-pickaxe() { git log -S"$1"; }
function git-delete-branch() { git branch -D $1; git push origin :$1; }
function git-checkout-topic() { git checkout -b ks_`slug $@`; }
function git-unsluggify-branch() { git-get-branch | sed -e 's/^ks_\(.*\)/\1/' -e 's/_/ /g'; }
function git-easy-pull-request() {
    git-checkout-topic $@ &&
    local message=$@;
    git add -p &&
    git commit -m "$message" &&
    git push origin `git-get-branch` -u &&
    git-pull-request $message;
}

function stage-gc { pushd ${CODE}/${REPO_PREFIX}systems/script && python stage.py $@; popd; }
function deploy-gc { pushd ${CODE}/${REPO_PREFIX}systems/script && python deploy.py $@; popd; }

function ssh-tunnel { ssh -f ${2} -L ${1}:localhost:${3} -N; }
function querysh { ssh -t batch1-prod 'sudo -u gcapp bash -c "source /gc/envs/prod/bin/activate; /gc/gcsystems/script/querysh prod"'; }

alias bounce="sudo apachectl restart"
alias bing="touch apache/local.wsgi"
alias blat="touch /sites/django/gcapi/apache/*.wsgi; touch /sites/django/gcweb/apache/*.wsgi; supervisorctl restart all"
alias stage="stage-gc"
alias deploy="deploy-gc"
alias stageme="stage-gc \$(git-get-branch)"

alias api="code api"
alias web="code web"
alias api2="code api2"
alias sys="code systems"
alias lib="code lib"
alias conf="code config"

alias gc="git commit"
alias ga="git add"
alias gs="git status"
alias gd="git diff"
alias gow="git show"
alias gash="git stash"
alias grb="git rebase"
alias gsync="git pull --rebase && git push origin \$(git-get-branch)"
alias gpr="git-pull-request \$(git-unsluggify-branch)"
alias ezpr="git-easy-pull-request"
alias gpx="git-pickaxe"
alias gpush="git push origin \$(git-get-branch)"
alias gpull="git pull --rebase"
alias gco="git checkout"
alias gb="git checkout -b"
alias g0="gco master"
alias gdbr="git-delete-branch"
alias start="git-checkout-topic"
alias done="git checkout master"
alias cleanup="git-delete-branch"

export PS1='\[\e[1;31m\]$(git-current-repo)\[\e[1;33m\]$(fancy-git-branch)\[\e[0;39m\]|\[\e[0;39m\]\W $ '

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
