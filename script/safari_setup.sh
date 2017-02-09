#!/bin/sh

# safariの初期設定script
# Dropbox内に置いてある各種設定を読み込むように変更する
#
# 対象は以下 TODO:これから追加していく
# * Extensions

source $HOME/dotfiles/etc/lib/vital.sh

e_header "start safari setup..."

dropbox=$HOME/Dropbox/backup/Safari
box_ext=$dropbox/Extensions

safari_lib=$HOME/Library/Safari
safari_ext=$safari_lib/Extensions

if [ ! -d $dropbox ]; then
  e_failure "Install Dropbox first!!"
fi

if [ ! -d $extention ]; then
  e_error "$extension dir doesn't exist. skip linking..."
elif [ ! -L $safari_ext ]; then
  e_header "start linking extensions..."
  if [ -d $safari_ext ]; then
    backup="$safari_ext-`/bin/date '+%Y%m%d-%H%M%S'`"
    e_arrow "backup $safari_ext to $backup"
    mv $safari_ext $backup
  fi
  ln -s $box_ext $safari_ext
  e_success "linking extensions"
fi

e_done "safari setup"
