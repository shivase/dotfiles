#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

zplug() {
  e_prompt "install zplug"
  if ! is_exists "zplug" ; then
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
else
  e_failure "install zsh first"
fi

