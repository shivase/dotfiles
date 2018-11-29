#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

DIR=$HOME/.iterm/colors

color_schemes() {
  e_prompt "install iterm color schemes to $DIR"

  if [ ! -d $DIR ];then
    mkdir -p $DIR
  fi

  wget https://raw.githubusercontent.com/aereal/dotfiles/master/colors/Japanesque/Japanesque.itermcolors -P $DIR
  wget https://raw.githubusercontent.com/hukl/Smyck-Color-Scheme/master/Smyck.itermcolors -P $DIR
  wget https://raw.githubusercontent.com/Arc0re/Iceberg-iTerm2/master/iceberg.itermcolors -P $DIR


  e_done "installed iterm color schemes"
}

color_schemes
