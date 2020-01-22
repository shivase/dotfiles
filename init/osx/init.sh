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

brew_install() {
  e_prompt "brew install start"
  brew install zsh
  brew install zplug
  brew install wget
  brew uninstall macvim
  brew install vim
  e_prompt "brew install finished"
}

e_header "initializing"

homebrew
brew_install

$CURRENT/fonts.sh
$CURRENT/zsh.sh
$CURRENT/iterm.sh

e_header "initialize finished."
