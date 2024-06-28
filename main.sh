#!/usr/bin/bash
export DOTFILES=$(pwd)
DOTFILES=$(pwd)

ln -sf $DOTFILES/.bashrc $HOME/.bashrc
rm -rf $DOTFILES/gitthings
SC="$DOTFILES/scripts/"
cd $SC
bash ./setup/bk-dots
bash ./setup/init
bash ./scripts/setup/link-config

source $HOME/.bashrc

bash ./install/main
# make newly installed fonts available
fc-cache -vf

# Install the window manager
bash ./setup/xmonad
bash ./install/xmonad

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."
echo "New step, you can logout from your current Ubuntu session, and chose XMonad,"
echo "instead of GNOME Window Manager. This choice is generally done at the login"
echo "interface."
