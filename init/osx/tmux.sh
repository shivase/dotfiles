#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

install_tools() {
  e_prompt "install tmux tools"
  # tmuxのヘッダーに表示するようのツール群を配置
  if [ ! -d /usr/local/bin ];then
    mkdir /usr/local/bin
  fi

  sudo cp $HOME/dotfiles/bin/battery /usr/local/bin
  sudo cp $HOME/dotfiles/bin/used_mem /usr/local/bin

  if [ ! -x /usr/local/bin/battery ]; then
    e_failure "coping dotfiles/bin"
  fi

  e_success "installed tmux tools"
}
