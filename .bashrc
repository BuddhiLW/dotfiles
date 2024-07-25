# BuddhiLW's setup
# ~/.bashrc
#
[[ $- == *i* ]] && source ~/dotfiles/gitthings/ble.sh/out/ble.sh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# alias ls='ls --color=auto'
# PS1='[\u@\h \W]\$ '
#!/usr/bin/bash
# shellcheck disable=SC1090

case $- in
    *i*) ;; # interactive
    *) return ;;
esac

# ---------------------- local utility functions ---------------------

_have() { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# ----------------------- environment variables ----------------------
#                           (also see envx)

# export USER="buddhilw"
export BOOKS="$DOCUMENTS/Books"
export CS_B="$BOOKS/CS"
export BNOTES="$PP/Notes/Books"
export BLOG="$PP/ClojureScript/Blobing"
export CONTENT="$BLOG/content"
export EVILDEEDS="$CONTENT/md/pages/US-tyranny.md"
export ELM_B="$CS_LANG_B/Elm"
export PP="$HOME/PP" #Programming Projects
export CS_LANG_B="$CS_B/Languages"
export GUIX_PROFILE="/home/$USER/.guix-profile" # Environmental variable for GUIX
export DOTFILES="$HOME/dotfiles/"
export INSTALL_SCRIPTS="$DOTFILES/scripts/install/"
export DOOMDIR="$HOME/.doom.d/"
export DOOM="$HOME/doom-emacs/"
export DOOMBIN="$DOOM/bin/"
export SCRIPTS="$DOTFILES/bin/"
export SNIPPETS="$DOTFILES/snippets"
export keg="$DOTFILES/keg"
export SEARX_SETTINGS_PATH="$HOME/.config/searx/"
export SNIPPETSROB="$DOTFILES/dotfiles-rob/snippets"
export HELP_BROWSER=lynx
export DESKTOP="$HOME/Desktop"
export DOCUMENTS="$HOME/Documents"
export WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Animated"
export PROGRAMMING="$HOME/Documents/Books/Programmig/"
export MATHEMATICS="$HOME/Documents/Books/Mathematics/"
export GENERAL="$HOME/Documents/Books/General/"
export DOWNLOADS="$HOME/Downloads"
export TEMPLATES="$HOME/Templates"
export PUBLIC="$HOME/Public"
export PRIVATE="$HOME/Private"
export PICTURES="$HOME/Pictures"
export MUSIC="$HOME/Music"
export VIDEOS="$HOME/Videos"
export TORB="$DOTFILES/gitthings/tor-browser"
export GODEV=""
export TERM=xterm-256color
export HRULEWIDTH=73
export GHCUP="$GHCUP_INSTALL_BASE_PREFIX/.ghcup/bin"
export GOPATH="$HOME/go"
export GOBIN="$HOME/go/bin"
export GOPRIVATE="github.com/orasis-holding/*"
export NATIVEFIER="$HOME/.local/nativefier"
#"/usr/local/go"
export GOROOT="/usr/local/go"
export PATH="$PATH:$GOROOT/bin"
export PATH="$PATH:$HOME/go/bin"
export LC_COLLATE=C
export LESS_TERMCAP_mb="[35m" # magenta
export LESS_TERMCAP_md="[33m" # yellow
export LESS_TERMCAP_me=""      # "0m"
export LESS_TERMCAP_se=""      # "0m"
export LESS_TERMCAP_so="[34m" # blue
export LESS_TERMCAP_ue=""      # "0m"
export LESS_TERMCAP_us="[4m"  # underline

[[ -d /.vim/spell ]] && export VIMSPELL=("$HOME/.vim/spell/*.add")

# ------------------------------- pager ------------------------------

if [[ -x /usr/bin/lesspipe ]]; then
    export LESSOPEN="| /usr/bin/lesspipe %s"
    export LESSCLOSE="/usr/bin/lesspipe %s %s"
fi

# ----------------------------- dircolors ----------------------------

if _have dircolors; then
    if [[ -r "$HOME/.dircolors" ]]; then
        eval "$(dircolors -b "$HOME/.dircolors")"
    else
        eval "$(dircolors -b)"
    fi
fi

# ------------------------------- path -------------------------------

pathappend() {
    declare arg
    for arg in "$@"; do
        test -d "$arg" || continue
        PATH=${PATH//":$arg:"/:}
        PATH=${PATH/#"$arg:"/}
        PATH=${PATH/%":$arg"/}
        export PATH="${PATH:+"$PATH:"}$arg"
    done
} && export pathappend

pathprepend() {
    for arg in "$@"; do
        test -d "$arg" || continue
        PATH=${PATH//:"$arg:"/:}
        PATH=${PATH/#"$arg:"/}
        PATH=${PATH/%":$arg"/}
        export PATH="$arg${PATH:+":${PATH}"}"
    done
} && export pathprepend

# remember last arg will be first in path
# "for 'fontfor' program and rust installs with cargo.
# # "$HOME/.guix-profile/bin/"
# "$HOME/.local/share/cargo/bin" \
# "$HOME/.local/bin" \
# "$HOME/.emacs.d/pen.el/scripts/" \
# . "$GUIX_PROFILE/etc/profile"

pathprepend \
    "$DOTFILES/.local/bin/" \
    "$DOTFILES/.local/bin/blw" \
    "$HOME/.local/bin/blw" \
    "$DOTFILES/.local/bin/larbs" \
    "$DOTFILES/.local/bin/rob-scripts/" \
    "$DOTFILES/.local/bin/statusbar" \
    "$DOTFILES/.local/julia/bin/" \
    "$HOME/.juliaup/bin/" \
    "$SCRIPTS" \
    "$SCRIPTS_INSTALL" \
    "$SCRIPTSROB" \
    "$GOPATH" \
    "$GOBIN" \
    "$DOOMBIN" \
    "$NATIVEFIER" \
    "$GHCUP" \
    "$GOROOT" \
    "$SEARX_SETTINGS_PATH" \
    "/usr/local/go/bin" \
		"/home/euler/.conda/envs/simple-signer-env/bin" \
    "$HOME/programs/julia/bin/" \
    "$GUIX_PROFILE/bin" \
    "$HOME/.emacs.d/bin/" \
    "$HOME/.conda/bin/" \
    "$HOME/.local/share/cargo/bin/"


pathappend \
    /usr/local/opt/coreutils/libexec/gnubin \
    /mingw64/bin \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/local/games \
    /usr/games \
    /usr/sbin \
    /usr/bin \
    /snap/bin \
    /sbin \
    /bin

# ------------------------------ cdpath ------------------------------

# export CDPATH=".:$GHREPOS:$DOT:$REPOS:/media/$USER:$HOME"

# ------------------------ bash shell options ------------------------

shopt -s checkwinsize
shopt -s expand_aliases
shopt -s globstar
shopt -s dotglob
shopt -s extglob
#shopt -s nullglob # bug kills completion for some
#set -o noclobber

# ------------------------------ history -----------------------------

export HISTCONTROL=ignoreboth
export HISTSIZE=5000
export HISTFILESIZE=10000

set -o vi
shopt -s histappend

# --------------------------- smart prompt ---------------------------
#                 (keeping in bashrc for portability)

PROMPT_LONG=20
PROMPT_MAX=95
PROMPT_AT=' ፠ ' # @ 𝄏 𖣐 ⌯

__ps1() { # g='\[\e[30m\]'
    local P='$' dir="${PWD##*/}" B countme short long double \
        r='\[\e[31m\]' g='\[\e[37m\]' h='\[\e[34m\]' \
        u='\[\e[33m\]' p='\[\e[33m\]' w='\[\e[35m\]' \
        b='\[\e[36m\]' x='\[\e[0m\]'

    [[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
    [[ $PWD = / ]] && dir=/
    [[ $PWD = "$HOME" ]] && dir='~'

    B=$(git branch --show-current 2>/dev/null)
    [[ $dir = "$B" ]] && B=.
    countme="$USER$PROMPT_AT:$dir($B)\$ "

    [[ $B = master || $B = main ]] && b="$r"
    [[ -n "$B" ]] && B="$g($b$B$g)"

    # short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$p$P$x $w(λ) "
    # long="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n$g╚ $p$P$x $w(λ) "
    # double="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir\n$g║ $B\n$g╚ $p$P$x $w(λ) "

    short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$w($pλ$w)$x "
    long="$g꧁ $u\u$g$PROMPT_AT$h\h$g ⟐ $w$dir$B\n$g꧂ $w($pλ$w)$x "
    double="$g꧁ $u\u$g$PROMPT_AT$h\h$g ⟐ $w$dir\n$g║ $B\n$g꧂ $w($pλ$w)$x "

    if ((${#countme} > PROMPT_MAX)); then
        PS1="$double"
    elif ((${#countme} > PROMPT_LONG)); then
        PS1="$long"
    else
        PS1="$short"
    fi
}

PROMPT_COMMAND="__ps1"

# ----------------------------- keyboard -----------------------------

_have setxkbmap && test -n "$DISPLAY" &&
    setxkbmap -option caps:escape &>/dev/null

# ------------------------------ aliases -----------------------------
#      (use exec scripts instead, which work from vim and subprocs)

# uim-fep

unalias -a
alias fctd="cd $HOME/PP/facti/linfo-ppi/"
alias reitfiles="cd $HOME/PP/Clojure/learn-reitit-course-files/"
alias reitpro="cd $HOME/Videos/Courses/Reitit-Pro"
alias ed="emacs --with-profile default"
alias ep="emacs --with-profile progress"
alias edoom="emacs --with-profile doom"
alias e="emacs --with-profile"
alias zt="zathura"
alias ecf="$DOOMDIR/config"
alias lynx="lynx --display_charset=utf-8"
alias apt-upgrade="sudo apt-get update && sudo apt-get upgrade"
# alias emacs="emacs-30.0.50"
#### Directory easyeness
alias csb='. csb'
alias elmb='cd $ELM_B'
# alias emacs="emacsclient -t"
#
alias '?'=duck
alias '??'=google
alias '???'=bing
alias dot='cd $DOTFILES'
alias prog='cd $PROGRAMMING'
alias scripts='cd $SCRIPTS'
alias scriptsr='cd $SCRIPTS-ROB'
alias snippets='cd $SNIPPETS'
alias snippetsr='cd $SNIPPETS-ROB'
alias gbud='cd $GOPATH/src/github.com/BuddhiLW/'
alias ls='ls -h --color=auto'
alias free='free -h'
alias df='df -h'
alias chmox='chmod +x'
alias sshh='sshpass -f $HOME/.sshpass ssh '
alias temp='cd $(mktemp -d)'
alias view='vi -R' # which is usually linked to vim
alias c='printf "\e[H\e[2J"'
alias clear='printf "\e[H\e[2J"'
alias coin="clip '(yes|no)'"
alias grep="grep -P"
alias minidockenv=". <(minikube docker-env)"
# alias torb="start-tor-browser"
alias books="cd $BOOKS"
alias zp="zhpron"

_have vim && alias vi=vim

# ----------------------------- functions ----------------------------

envx() {
    local envfile="${1:-"$HOME/.env"}"
    [[ ! -e "$envfile" ]] && echo "$envfile not found" && return 1
    while IFS= read -r line; do
        name=${line%%=*}
        value=${line#*=}
        [[ -z "${name}" || $name =~ ^# ]] && continue
        export "$name"="$value"
    done <"$envfile"
} && export -f envx

[[ -e "$HOME/.env" ]] && envx "$HOME/.env"

new-from() {
    local template="$1"
    local name="$2"
    ! _have gh && echo "gh command not found" && return 1
    [[ -z "$name" ]] && echo "usage: $0 <name>" && return 1
    #    [[ -z "$GHREPOS" ]] && echo "GHREPOS not set" && return 1
    #    [[ ! -d "$GHREPOS" ]] && echo "Not found: $GHREPOS" && return 1
    #    cd "$GHREPOS" || return 1
    [[ -e "$name" ]] && echo "exists: $name" && return 1
    gh repo create -p "$template" "$name"
    cd "$name" || return 1
}

new-cmdbox() { new-from rwxrob/template-cmdbox "cmdbox-$1"; }
new-cmd() { new-from rwxrob/template-bash-command "cmd-$1"; }

export -f new-from new-cmdbox new-cmd

# ------------- source external dependencies / completion ------------

owncomp=(
    pdf md zet yt gl auth pomo config iam sshkey ws x clip
    ./build build b ./setup ./cmd
)

for i in "${owncomp[@]}"; do complete -C "$i" "$i"; done

_have gh && . <(gh completion -s bash)
_have pandoc && . <(pandoc --bash-completion)
_have kubectl && . <(kubectl completion bash)
_have clusterctl && . <(clusterctl completion bash)
_have k && complete -o default -F __start_kubectl k
_have kind && . <(kind completion bash)
_have yq && . <(yq shell-completion bash)
_have helm && . <(helm completion bash)
_have minikube && . <(minikube completion bash)
_have mk && complete -o default -F __start_minikube mk
_have docker && _source_if "$HOME/.local/share/docker/completion" # d
_have podman && _source_if "$HOME/.local/share/podman/completion" # d

# -------------------- personalized configuration --------------------
_source_if "$HOME/.bash_personal"
_source_if "$HOME/.bash_private"
_source_if "$HOME/.bash_work"

# Default programs:
export EDITOR="vim"
export VISUAL="vim"
## export EDITOR="emacsclient -t"                  # $EDITOR opens in terminal
## export VISUAL="emacsclient -c -a emacs"         # $VISUAL opens in GUI mode
export TERMINAL="st"
#export BROWSER="qutebrowser"
export BROWSER="chromium"

# PPI related
export LINFO="$HOME/facti/linfo-ppi"

# Clojure related
export CLJ="$HOME/PP/Clojure/"
export CLJ_PLAYGROUND="$CLJ/cljs-reagent-template/"

# ~/ Clean-up:
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XINITRC="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xinitrc"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/shell/inputrc"
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
#export ALSA_CONFIG_PATH="$XDG_CONFIG_HOME/alsa/asoundrc"
#export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"
export WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/default"
export KODI_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/kodi"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
# export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"
export UNISON="${XDG_DATA_HOME:-$HOME/.local/share}/unison"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export WEECHAT_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/weechat"
export MBSYNCRC="${XDG_CONFIG_HOME:-$HOME/.config}/mbsync/config"
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"
export SEARX_SETTINGS_PATH="${XDG_DATA_HOME:-$HOME/.config}/searx"
# Other program settings:
export DICS="/usr/share/stardict/dic/"
export SUDO_ASKPASS="$HOME/.local/bin/dmenupass"
export FZF_DEFAULT_OPTS="--layout=reverse --height 40%"
export LESS=-R
export LESS_TERMCAP_mb="$(printf '%b' '[1;31m')"
export LESS_TERMCAP_md="$(printf '%b' '[1;36m')"
export LESS_TERMCAP_me="$(printf '%b' '[0m')"
export LESS_TERMCAP_so="$(printf '%b' '[01;44;33m')"
export LESS_TERMCAP_se="$(printf '%b' '[0m')"
export LESS_TERMCAP_us="$(printf '%b' '[1;32m')"
export LESS_TERMCAP_ue="$(printf '%b' '[0m')"
export LESSOPEN="| /usr/bin/highlight -O ansi %s 2>/dev/null"
export QT_QPA_PLATFORMTHEME="gtk2"        # Have QT use gtk2 theme.
export MOZ_USE_XINPUT2="1"                # Mozilla smooth scrolling/touchpads.
export AWT_TOOLKIT="MToolkit wmname LG3D" #May have to install wmname
export _JAVA_AWT_WM_NONREPARENTING=1      # Fix for Java applications in dwm

# This is the list for lf icons:
export LF_ICONS="di=📁:\
    fi=📃:\
    tw=🤝:\
    ow=📂:\
    ln=⛓:\
    or=❌:\
    ex=🎯:\
    *.txt=✍:\
    *.mom=✍:\
    *.me=✍:\
    *.ms=✍:\
    *.png=🖼:\
    *.webp=🖼:\
    *.ico=🖼:\
    *.jpg=📸:\
    *.jpe=📸:\
    *.jpeg=📸:\
    *.gif=🖼:\
    *.svg=🗺:\
    *.tif=🖼:\
    *.tiff=🖼:\
    *.xcf=🖌:\
    *.html=🌎:\
    *.xml=📰:\
    *.gpg=🔒:\
    *.css=🎨:\
    *.pdf=📚:\
    *.djvu=📚:\
    *.epub=📚:\
    *.csv=📓:\
    *.xlsx=📓:\
    *.tex=📜:\
    *.md=📘:\
    *.r=📊:\
    *.R=📊:\
    *.rmd=📊:\
    *.Rmd=📊:\
    *.m=📊:\
    *.mp3=🎵:\
    *.opus=🎵:\
    *.ogg=🎵:\
    *.m4a=🎵:\
    *.flac=🎼:\
    *.wav=🎼:\
    *.mkv=🎥:\
    *.mp4=🎥:\
    *.webm=🎥:\
    *.mpeg=🎥:\
    *.avi=🎥:\
    *.mov=🎥:\
    *.mpg=🎥:\
    *.wmv=🎥:\
    *.m4b=🎥:\
    *.flv=🎥:\
    *.zip=📦:\
    *.rar=📦:\
    *.7z=📦:\
    *.tar.gz=📦:\
    *.z64=🎮:\
    *.v64=🎮:\
    *.n64=🎮:\
    *.gba=🎮:\
    *.nes=🎮:\
    *.gdi=🎮:\
    *.1=ℹ:\
    *.nfo=ℹ:\
    *.info=ℹ:\
    *.log=📙:\
    *.iso=📀:\
    *.img=📀:\
    *.bib=🎓:\
    *.ged=👪:\
    *.part=💔:\
    *.torrent=🔽:\
    *.jar=♨:\
    *.java=♨:\
    "

[ -f $HOME/.config/shell/shortcutrc ] && . $HOME/.config/shell/shortcutrc

[ -f ${XDG_CONFIG_HOME}/shell/shortcutrc ] || shortcuts >/dev/null 2>&1 &

# Switch escape and caps if tty and no passwd required:
sudo -n loadkeys ${XDG_DATA_HOME/share/}/larbs/ttymaps.kmap 2>/dev/null

newshell

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/euler/.conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/euler/.conda/etc/profile.d/conda.sh" ]; then
        . "/home/euler/.conda/etc/profile.d/conda.sh"
    else
        export PATH="/home/euler/.conda/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

complete -C keg keg
# complete -C guix guix

#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
#export PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig/fontconfig.pc

# . "/home/lw/.local/share/cargo/env"

# Automatically added by the Guix install script.
#if [ -n "$GUIX_ENVIRONMENT" ]; then
#    if [[ $PS1 =~ (.*)"\\$" ]]; then
#        PS1="${BASH_REMATCH[1]} [env]\\\$ "
#    fi
#fi

# export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
# guix install glibc-locales

# uim: univeral input method
#export GTK_IM_MODULE=uim
#export QT_IM_MODULE=uim
#uim-xim &
export GUIX_LOCPATH="$HOME/.guix-profile/lib/locale"
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_AVD_HOME=$HOME/Android/system-images/
#export XMODIFIERS=@im=uim

[[ ${BLE_VERSION-} ]] && ble-attach

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/lw/google-cloud-sdk/path.bash.inc' ]; then . '/home/lw/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/lw/google-cloud-sdk/completion.bash.inc' ]; then . '/home/lw/google-cloud-sdk/completion.bash.inc'; fi

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/euler/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/euler/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<
complete -C go go 
complete -C lazywal lazywal
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
. "/home/euler/.local/share/cargo/env"

## Nix
source $HOME/.nix-profile/etc/profile.d/nix.sh
