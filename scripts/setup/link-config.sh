#!/usr/bin/sh

LINKS=("tmux/.tmux.conf" "vim/.vimrc")

link() {
  ln -sf $HOME/.config/$1 $HOME
}

for i in "${LINKS[@]}"; do
  link $i
done

