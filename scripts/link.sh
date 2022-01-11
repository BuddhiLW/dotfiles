#!/usr/bin/env bash

homonyms() { echo "ln $PWD/$1 $HOME/.$1"; }
emacs-conf() { echo "ln $PWD/$1 $HOME/.$1.d"; }

# Declare an array of string with type
declare -a dots=("local" "config" "bashrc" "doom")

# Iterate the string array using for loop
for dot in "${dots[@]}"; do
# syntax sugar for [ "$dot" == "local" ] || [ "$dot" == "config" ] || [ "$dot" == "bashrc" ]
    if [[ "$dot" =~ ^(local|config|bashrc)$ ]]; then
        homonyms $dot
    else [ "$dot" == "doom" ]
         emacs-conf $dot
    fi
done
