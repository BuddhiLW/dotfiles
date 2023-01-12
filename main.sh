#/usr/bin/bash
SC="$DOTFILES/scripts/"
cd $SC
basg ./setup/bk-dots
bash ./setup/init
bash ./install/main
bash ./setup/link-config
bash ./setup/xmonad

echo "Congrats. If everything went well, you have the newest Buddhi WM installed."

