#!/bin/sh

CURRENT=`echo $(cd $(dirname $0);pwd)`

. "$DOTPATH"/etc/lib/vital.sh

homebrew() {
  e_prompt "installing homebrew"
  brew_dir=/usr/local/bin
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  if [ ! -f $brew_dir/brew ]; then
    sudo mkdir $brew_dir
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    e_success "homebrew installed"
  else
    e_skip
  fi
}

change_hostname() {
  e_prompt "changing hostname"
  hostname=`scutil --get ComputerName`
  if [ ! "$hostname" = "kegamin" ]; then
    sudo scutil --set ComputerName kegamin
    sudo scutil --set LocalHostName kegamin
    e_success "changed hostname"
  else
    e_skip
  fi
}

e_header "initializing"


change_hostname
homebrew

$CURRENT/fonts.sh
$CURRENT/zsh.sh
$CURRENT/tmux.sh
$CURRENT/iterm.sh

e_header "initialize finished."
