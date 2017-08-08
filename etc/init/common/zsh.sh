#!/bin/sh

. $HOME/dotfiles/etc/lib/vital.sh
curl -sL https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

current_shell=`grep $(whoami) /etc/passwd | cut -d':' -f7`
zsh_path=$(which zsh)

## /etc/shellsにzsh追加
if ! grep $zsh_path /etc/shells > /dev/null 2>&1 ; then
  e_header "/etc/shellに$zsh_pathを追加します."
  echo $zsh_path | sudo tee -a /etc/shells
fi

if [ "$current_shell" != "$zsh_path" ]; then
  e_header "changing default login shell to $zsh_path"
  #zshをデフォルトのshellに
  chsh -s $zsh_path
fi
