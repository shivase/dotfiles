#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

DIR=$HOME/.iterm/colors

color_schemes() {
  e_prompt "install iterm color schemes to $DIR"

  if [ ! -d $DIR ];then
    mkdir -p $DIR
  fi

  wget https://raw.githubusercontent.com/aereal/dotfiles/master/colors/Japanesque/Japanesque.itermcolors -p $DIR

  e_done "installed iterm color schemes"
}

color_schemes
