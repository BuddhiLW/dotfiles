#!/usr/bin/env bash

## Helper function
installpkg(){ pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 ;}

opt="--needed --noconfirm"

## bash start setup
yay -Sy figlet lolcat fortune

## us intl with modfier keys
sudo cp 00-keyboard.conf /etc/X11/xorg.conf.d/

## Management tools
yay -Sy openpomodoro

### Spell checking
yay -S --needed --noconfirm hunspell hunspell-en_us hunspell-pt-br ispell
yay -Sy --needed --noconfirm ispell aspell aspell-en aspell-pt

## Programming languages
## Go
pacman -S  go
mkdir -p ~/go/src

## Purescript
yay -S $opt purescript-bin
