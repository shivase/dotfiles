#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

e_header "install ricty fonts"

# installing ricty fonts
ricty_ver=`ls -1 /usr/local/Cellar/ricty/`;
if [ -d /usr/local/Cellar/ricty/${ricty_ver}/share/fonts ]; then
  echo "install ricty font, and clean font caches..."
  # rictyフォントをコピーして,フォントキャッシュをクリアする
  cp -f /usr/local/Cellar/ricty/${ricty_ver}/share/fonts/Ricty*.ttf ~/Library/Fonts/
  fc-cache -vf
  defaults -currentHost write -globalDomain AppleFontSmoothing -int 2
else
  e_error "rictyのフォントが未インストール."
fi

e_done "ricty fonts"
