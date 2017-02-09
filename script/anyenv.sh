#!/bin/sh

. $HOME/dotfiles/etc/lib/vital.sh

# anyenvはgit submoduleで入ってるのでinstallは不要
# updateして最新版の**envを入れていく.

if ! has anyenv; then
  e_failure "anyenv command not found."
fi

e_newline
e_header "update anyenv and installing **env"
anyenv update

if ! has rbenv; then
  anyenv install rbenv
  e_success "installed rbenv"
else
  e_arrow "rbenv already installed"
fi
if ! has pyenv; then
  anyenv install pyenv
  e_success "installed pyenv"
else
  e_arrow "pyenv already installed"
fi
if ! has plenv; then
  anyenv install plenv
  e_success "installed plenv"
else
  e_arrow "plenv already installed"
fi
if ! has ndenv; then
  anyenv install ndenv
  e_success "installed ndenv"
else
  e_arrow "ndenv already installed"
fi
e_done "update anyenv and installing **env finished"

anyenv_plugins="$(anyenv root)/plugins"
if [ ! -d $anyenv_plugins/anyenv-update ];then
  e_header "install anyenv-update"
  mkdir -p $anyenv_plugins
  git clone https://github.com/znz/anyenv-update.git \
      $anyenv_plugins/anyenv-update
  e_done "anyenv-update installed"
else
  e_arrow "anyenv-update already installed."
fi

e_header "install **env utilities"

# rbenv utilities
rbenv_plugins="$HOME/.rbenv/plugins"
if [ ! -d $rbenv_plugins/rbenv-gem-rehash ];then
  e_header "install rbenv-gem-rehash"
  git clone https://github.com/sstephenson/rbenv-gem-rehash.git \
   $rbenv_plugins/rbenv-gem-rehash
  e_success "rbenv-gem-rehash installed"
else
  e_arrow "rbenv-gem-rehash already installed."
fi

e_done "**env utilities installed"

exec $SHELL -l
