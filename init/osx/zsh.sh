#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

current_shell=`echo $SHELL`
zsh_path="/usr/local/bin/zsh"

default() {
  e_prompt "make zsh default shell"
  if ! grep $zsh_path /etc/shells > /dev/null 2>&1 ; then
    echo $zsh_path | sudo tee -a /etc/shells
  fi

  if [ "$current_shell" != "$zsh_path" ]; then
    chsh -s $zsh_path
  fi
  e_success "finished make zsh default"
}

zplug() {
  e_prompt "install zplug"
  if is_exists "zplug" ; then
    e_newline
    curl -sL https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    if [ $? -ne 0 ]; then
      e_failure "zplug installer failed"
    fi
    e_success "installed zplug"
  else
    e_skip
  fi
}


if is_exists "zsh"; then
  zplug
  default
else
  e_failure "install zsh first"
fi

