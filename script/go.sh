#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

e_header "install go plugins"
if has go; then
  # peco
  go get github.com/peco/peco/cmd/peco

  # ttyrecのデータをgif化するツール
  go get github.com/sugyan/ttyrec2gif

  # vagrant-global-status
  go get github.com/monochromegane/vagrant-global-status/
  cd $HOME/go/src/github.com/monochromegane/vagrant-global-status/cmd/vagrant-global-status/ && go install
else
  e_error "go command doesn't exist. skip installing plugins."
fi

e_done "install go plugins"
