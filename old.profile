export PATH=$PATH:/usr/local/mysql/bin:/opt/git/bin
export ANT_OPTS=-Xmx2000M
export PYTHONSTARTUP=~/.python
export PYTHONPATH=.:/sites/django
export DJANGO_SETTINGS_MODULE=gcapi.settings

# git aliases
alias gs="git status"
alias gc="git commit"
alias ga="git add"
alias gr="git remove"
alias gd="git diff"
alias gsh="git show"
alias push="git push"
alias pull="git pull"
alias co="git checkout"
alias pick="git cherry-pick"
alias branch="git branch"

# Helpers
alias bounce="sudo apachectl restart"
alias bing="touch apache/local.wsgi"
alias blat="touch /sites/django/gcapi/apache/*.wsgi; touch /sites/django/gcweb/apache/*.wsgi; supervisorctl restart all"

# Personal Quick-Jump navigation
alias phone="cd ~/code/gc/iphone"
alias web="cd ~/code/gc/web"
alias and="cd ~/code/gc/android"
alias js="cd ~/code/gc/web.js"
alias lib="cd ~/code/gc/gclib"
alias api="cd ~/code/gc/api"
alias a="api"
alias api2="cd ~/code/gc/api"
alias a2="api2"
alias sys="cd ~/code/gc/systems"
alias code="cd ~/code/"
alias hoops="cd ~/code/gc/hoops"
alias bats="cd ~/code/gc/gcios_batsi"

test -r /sw/bin/init.sh && . /sw/bin/init.sh

alias gcpid="ps alx | grep GC.app | grep -v grep | awk '{print \$2}'"
alias gcatos="atos -p \`gcpid\`"
alias todos="grep -E -o '// *TODO.*' \`find -E . -regex '.*\.h|.*\.m'\`"

# Android Stuff
export PATH=/usr/local/android/tools/:/usr/local/android/platform-tools/:$PATH

# EC2 stuff
export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Home
export EC2_HOME=/usr/local/ec2
export EC2_PRIVATE_KEY=~/.ec2/pk-Z7A6FSWQJ65GA7HZPTYM5BVTNMZZCJH3.pem
export EC2_CERT=~/.ec2/cert-Z7A6FSWQJ65GA7HZPTYM5BVTNMZZCJH3.pem

export PATH=$PATH:$EC2_HOME/bin

# Arc
alias arc3="/usr/share/mzscheme372/bin/mzscheme -f /Users/aurumaeus/code/oss/arc3/as.scm"

export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

function stage { pushd ~/code/gc/systems/script && python stage.py $1; popd; }
function deploy { pushd ~/code/gc/systems/script && python deploy.py $1; popd; }

function get_git_branch() { git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'; }
function parse_git_branch() { echo " → `get_git_branch`"; }
function dbranch { echo "git branch -d $1"; git branch -d $1 && echo "git push origin :$1"; git push origin :$1; }
function gpr { echo "hub pull-request \"$1\" -h gamechanger:`get_git_branch`"; hub pull-request "$1" -h gamechanger:`get_git_branch`; }

#export PS1="@\[\e[1;37m\]\W \[\e[0;36m\]\t\[\e[0m\]/\[\e[0;33m\]\!\[\e[1;37m\] $ \[\e[0m\]"
export PS1='\u\[\e[1;37m\]:\[\e[1;31m\]\W\[\e[1;33m\]$(parse_git_branch)\[\e[0;39m\]$ '

export C_INCLUDE_PATH=$C_INCLUDE_PATH:/Developer/SDKs/MacOSX10.6.sdk/usr/include
export LIBRARY_PATH=$LIBRARY_PATH:/Developer/SDKs/MacOSX10.6.sdk/usr/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/Developer/SDKs/MacOSX10.7.sdk/usr/include
export LIBRARY_PATH=$LIBRARY_PATH:/Developer/SDKs/MacOSX10.7.sdk/usr/lib

alias gsync="git pull --rebase && git push origin master"
