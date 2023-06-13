#!/usr/bin/bash
UBUNTU=${uname-a | grep "Ubuntu"}

rm -rf $DOTFILES/gitthings
SC="$DOTFILES/scripts/"
cd $SC
bash ./setup/bk-dots
bash ./setup/init
bash ./install/main
fc-cache -vf
bash ./setup/link-config
bash ./setup/xmonad

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."
