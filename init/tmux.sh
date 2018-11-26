#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

tpm() {
  e_prompt "install tpm(tmux plugin manager)"
  if [ ! -d $HOME/.tmux/plugins/tpm ]; then
    mkdir -p $HOME/.tmux/plugins
    git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
  else
    e_skip
  fi

}

tpm
