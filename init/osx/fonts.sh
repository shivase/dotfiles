#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

powerline() {
  e_prompt "install powerline fonts"
  exists=`ls $HOME/Library/Fonts | grep Powerline | wc -l`
  if [ $exists -eq 0 ]; then
    temp_dir=$(mktemp -d)
    cd $temp_dir
    git clone https://github.com/powerline/fonts.git && cd fonts && ./install.sh
    if [ $? -eq 0 ]; then
      e_success "installed powerline"
      rm -rf $temp_dir
    else
      e_failure
    fi
  else
    e_skip
  fi
}

ricty() {
  e_prompt "install ricty fonts"
  exists=`ls $HOME/Library/Fonts | grep Ricty | wc -l`
  if [ $exists -eq 0 ]; then
    temp_dir=$(mktemp -d)
    cd $temp_dir
    git clone https://github.com/mzyy94/RictyDiminished-for-Powerline.git
    cd RictyDiminished-for-Powerline
    cp ./powerline-fontpatched/*.ttf $HOME/Library/Fonts/
    fc-cache $HOME/Library/Fonts
    e_success "installed ricty"
    rm -rf $temp_dir
  else
    e_skip
  fi
}

powerline
ricty
