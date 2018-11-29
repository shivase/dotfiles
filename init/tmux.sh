#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

tpm() {
  e_prompt "install tpm(tmux plugin manager)"
  TPM_PATH=$HOME/.tmux/plugins
  if [ ! -d ${TPM_PATH}/tpm ]; then
    mkdir -p ${TPM_PATH}
    cd ${TPM_PATH} && git clone https://github.com/tmux-plugins/tpm
  else
    e_skip
  fi

}

tpm
