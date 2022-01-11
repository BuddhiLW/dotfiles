#!/usr/bin/env bash

cdPP() {
    dir=${1:-PP}
    echo "cd $HOME/$dir";
}

echo "cd $HOME" && echo "git clone https://github.com/BuddhiLW/buddhi-roam"

echo "touch "$HOME/PP"" && echo "cd "$HOME/PP""
echo "touch ClojureScript" && echo "cd ClojuresCript" && echo "git clone https://github.com/BuddhiLW/Blobing"

echo "touch "$HOME/PP/gitthings"" && cdPP gitthings
echo "git clone --recursive https://github.com/akinomyoga/ble.sh.git && cd ble.sh && make"
