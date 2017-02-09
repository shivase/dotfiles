#!/bin/sh

source $HOME/dotfiles/etc/lib/vital.sh

e_header "Creating new user..."
e_prompt "Input a new username"
read NEWUSER

check=`cut -d':' -f1 /etc/passwd | grep $NEWUSER`
if [ -n "$check" ]; then
    e_error "$NEWUSER is already added. skip to add the user."
      exit 0;
fi

sudo adduser $NEWUSER
sudo usermod -G wheel $NEWUSER
sudo passwd $NEWUSER

sudoers_file=/etc/sudoers.d/$NEWUSER
cat << EOF | sudo tee $sudoers_file >/dev/null
$NEWUSER ALL = NOPASSWD: ALL

# User rules for $NEWUSER
$NEWUSER ALL=(ALL) NOPASSWD:ALL
EOF

