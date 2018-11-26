#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

# bundleで入れたもので、system vimを上書き
new_vim=`ls -1 /usr/local/Cellar/vim/*/bin/vim`;
if [ -f ${new_vim} ]; then
  e_newline
  e_header "linking latest brewed vim ..."
  if [ ! -f /usr/bin/vim_old ]; then
    sudo mv /usr/bin/vim /usr/bin/vim_old
  fi
  sudo ln -s `ls -1 /usr/local/Cellar/vim/*/bin/vim` /usr/bin 2> /dev/null
  e_done "installed."
else
  e_arrow "latest vim is already installed."
fi

"$DOTPATH"/etc/init/common/vim.sh

