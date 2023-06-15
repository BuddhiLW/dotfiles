#!/usr/bin/bash
#UBUNTU=${uname-a | grep "Ubuntu"}

ln -sf $DOTFILES/.bashrc $HOME/.bashrc
rm -rf $DOTFILES/gitthings

SC="$DOTFILES/scripts/"
cd $SC
bash ./setup/bk-dots
bash ./setup/init

source $HOME/.bashrc

bash ./install/main
fc-cache -vf
bash ./setup/link-config
bash ./setup/xmonad

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."
