#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

brew_dir=/usr/local/bin
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if [ ! -f $brew_dir/brew ]; then
  e_header "install homebrew"
  sudo mkdir $brew_dir
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  e_done "installed."
else
  e_arrow "homebrew already installed."
fi

if [ -d /usr/local/Libraly ]; then
  cd /usr/local/Library && git stash && git clean -d -f
fi

e_header "install brew-file and install all Brewfiles"
# brew-fileを利用して各種brewをinstallするので前準備
brew install rcmdnk/file/brew-file
brew file set_repo -r kegamin/Brewfile
brew file install
brew file clean -C
e_arrow "install finished."

