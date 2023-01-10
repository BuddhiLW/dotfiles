#!/usr/bin/env bash

## Helper function
installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}

opt="--needed --noconfirm"

## bash start setup
yay -Syu figlet lolcat fortune

## us intl with modfier keys
sudo cp low-level/00-keyboard.conf /etc/X11/xorg.conf.d/

## Management tools
# yay -Syu openpomodoro

### Spell checking
yay -S --needed --noconfirm hunspell hunspell-en_us hunspell-pt-br ispell
yay -Sy --needed --noconfirm ispell aspell aspell-en aspell-pt

## Programming languages
## Go
# pacman -S  go
# mkdir -p ~/go/src

## Purescript
# yay -S $opt purescript-bin

yay -Syu sof-firmware nvidia nvidia-prime
yay -Syu picom-ibhagwan-git
yay -Syu bash-completion
# yay -Syu all-repository-fonts
yay -Syu ttf-sarasa-gothic ttf-sarasa-ui-sc
yay -Syu noto-fonts-main
yay -Syu emacs-all-the-icons ttf-all-the-icons
yay -Syu ttf-fantasque-sans-git nerd-fonts-fantasque-sans-mono
yay -Syu nerd-fonts-complete
yay -Syu pulseaudio-jack pulseaudio-bluetooth pulseaudio-alsa
yay -Syu jack2 jack2-dbus cadence jack-rack
yay -Syu tor tor-browser

sudo ln -s /etc/runit/sv/tor/ /run/runit/service/
# yay -Syu trasmission-cli tremc transmission-git

yay -Syu transmission-runit tremc
sudo ln -s /etc/runit/sv/transmission-daemon/ /run/runit/service/

yay -Syu realtime-privileges
sudo usermod -a -G realtime buddhilw

yay -Syu urlview-git
