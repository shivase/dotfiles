#!/bin/sh

# 最新版のvimをgitから取ってきてinstallする
# 特に+clipboardとかにするため

source $HOME/dotfiles/etc/lib/vital.sh

e_header "install latest vim"

# 必要なパッケージinstall
sudo yum -y install ncurses-devel gtk2-devel atk-devel libX11-devel libXt-devel lua-devel

if [ -d /usr/local/src/vim ]; then
  e_arrow "delete old src at /usr/local/src/vim"
  cd /usr/local/src/vim && make clean
  sudo rm -rf /usr/local/src/vim
fi

cd /usr/local/src
sudo git clone https://github.com/vim/vim.git

if [ ! -d /usr/local/src/vim ]; then
  e_failure "error while executing git clone..."
fi

cd /usr/local/src/vim
sudo ./configure \
  --prefix=/usr/local \
  --with-features=huge \
  --enable-multibyte \
  --enable-cscope \
  --enable-gui=gtk2 \
  --enable-xim
  --enable-fontset \
  --enable-gpm \
  --enable-rubyinterp \
  --enable-luainterp=yes --with-lua-prefix=/usr \
  --disable-selinux

sudo make && sudo make install
e_header "---------- show vim version info below ----------"
/usr/local/bin/vim --version | head -4
e_header "-------------------------------------------------"

sudo mv /bin/vim /bin/vim.old
sudo ln -s /usr/local/bin/vim /bin/vim
e_done "install latest vim to /usr/local/bin/vim"
