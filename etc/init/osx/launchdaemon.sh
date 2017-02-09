#!/bin/sh

# -------------------------------------------------
# mac locate commandのupdateを自動化
# -------------------------------------------------

. "$DOTPATH"/etc/lib/vital.sh

diff=`diff /System/Library/LaunchDaemons/com.apple.locate.plist $HOME/dotfiles/etc/launchctl/com.apple.locate.plist`
if [ $? -ne 0 ];then
  e_header "update locate.plist..."
  sudo cp -f $HOME/dotfiles/etc/launchctl/com.apple.locate.plist /System/Library/LaunchDaemons/com.apple.locate.plist
  sudo launchctl unload /System/Library/LaunchDaemons/com.apple.locate.plist
  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
  e_done "update locate.plist"
else
  e_arrow "locate plist is already installed"
fi

