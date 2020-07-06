#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

zplug() {
  e_prompt "install zplug"
  if which zplug >/dev/null 2>&1; then
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

prompt_pure() {
  e_prompt "install prompt pure"
  if [ ! -f "$HOME/.zfunctions/prompt_pure_setup" ]; then
    e_newline
    if [ ! -f "$HOME/.zfunctions" ]; then
      mkdir $HOME/.zfunctions
    fi
    curl -o $HOME/.zfunctions/prompt_pure_setup https://raw.githubusercontent.com/intelfx/pure/master/pure.zsh
    if [ $? -ne 0 ]; then
      e_failure "prompt pure installer failed"
    fi
    e_success "installed prompt pure"
  else
    e_skip
  fi
}

if is_exists "zsh"; then
  zplug
  prompt_pure
else
  e_failure "install zsh first"
fi

