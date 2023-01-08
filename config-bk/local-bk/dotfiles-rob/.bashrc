#!/usr/bin/bash
# shellcheck disable=SC1090

case $- in
*i*) ;; # interactive
*) return ;; 
esac

# ---------------------- local utility functions ---------------------

_have()      { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# ----------------------- environment variables ----------------------
#                           (also see envx)

export USER="$(whoami)"
export GITUSER="$USER"
export REPOS="$HOME/Repos"
export GHREPOS="$REPOS/github.com/$GITUSER"
export DOTFILES="$GHREPOS/dot"
export SCRIPTS="$DOTFILES/scripts"
export SNIPPETS="$DOTFILES/snippets"
export HELP_BROWSER=lynx
export DESKTOP="$HOME/Desktop"
export DOCUMENTS="$HOME/Documents"
export DOWNLOADS="$HOME/Downloads"
export TEMPLATES="$HOME/Templates"
export PUBLIC="$HOME/Public"
export PRIVATE="$HOME/Private"
export PICTURES="$HOME/Pictures"
export MUSIC="$HOME/Music"
export VIDEOS="$HOME/Videos"
export PDFS="$DOCUMENTS/PDFS"
export VIRTUALMACHINES="$HOME/VirtualMachines"
export WORKSPACES="$HOME/Workspaces" # container home dirs for mounting
export ZETDIR="$GHREPOS/zet"
export ZETTELCASTS="$VIDEOS/ZettelCasts"
export CLIP_DIR="$VIDEOS/Clips"
export CLIP_DATA="$GHREPOS/cmd-clip/data"
export CLIP_VOLUME=0
export CLIP_SCREEN=0
export TERM=xterm-256color
export HRULEWIDTH=73
export EDITOR=vi
export VISUAL=vi
export EDITOR_PREFIX=vi
export GOPRIVATE="github.com/$GITUSER/*,gitlab.com/$GITUSER/*"
export GOPATH="$HOME/.local/share/go"
export GOBIN="$HOME/.local/bin"
export GOPROXY=direct
export CGO_ENABLED=0
export PYTHONDONTWRITEBYTECODE=2 # fucking shit-for-brains var name
export LC_COLLATE=C
export LESS_TERMCAP_mb="[35m" # magenta
export LESS_TERMCAP_md="[33m" # yellow
export LESS_TERMCAP_me="" # "0m"
export LESS_TERMCAP_se="" # "0m"
export LESS_TERMCAP_so="[34m" # blue
export LESS_TERMCAP_ue="" # "0m"
export LESS_TERMCAP_us="[4m"  # underline

[[ -d /.vim/spell ]] && export VIMSPELL=("$HOME/.vim/spell/*.add")

# ------------------------------- pager ------------------------------

if [[ -x /usr/bin/lesspipe ]]; then
  export LESSOPEN="| /usr/bin/lesspipe %s";
  export LESSCLOSE="/usr/bin/lesspipe %s %s";
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
pathprepend \
  /usr/local/go/bin \
  "$HOME/.local/bin" \
  "$GHREPOS/cmd-"* \
  "$SCRIPTS" 

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

export CDPATH=".:$GHREPOS:$DOT:$REPOS:/media/$USER:$HOME"

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
PROMPT_AT=@

__ps1() {
  local P='$' dir="${PWD##*/}" B countme short long double\
    r='\[\e[31m\]' g='\[\e[30m\]' h='\[\e[34m\]' \
    u='\[\e[33m\]' p='\[\e[34m\]' w='\[\e[35m\]' \
    b='\[\e[36m\]' x='\[\e[0m\]'

  [[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
  [[ $PWD = / ]] && dir=/
  [[ $PWD = "$HOME" ]] && dir='~'

  B=$(git branch --show-current 2>/dev/null)
  [[ $dir = "$B" ]] && B=.
  countme="$USER$PROMPT_AT$(hostname):$dir($B)\$ "

  [[ $B = master || $B = main ]] && b="$r"
  [[ -n "$B" ]] && B="$g($b$B$g)"

  short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$p$P$x "
  long="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n$g╚ $p$P$x "
  double="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir\n$g║ $B\n$g╚ $p$P$x "

  if (( ${#countme} > PROMPT_MAX )); then
    PS1="$double"
  elif (( ${#countme} > PROMPT_LONG )); then
    PS1="$long"
  else
    PS1="$short"
  fi
}

PROMPT_COMMAND="__ps1"

# ----------------------------- keyboard -----------------------------

_have setxkbmap && test -n "$DISPLAY" && \
  setxkbmap -option caps:escape &>/dev/null

# ------------------------------ aliases -----------------------------
#      (use exec scripts instead, which work from vim and subprocs)

unalias -a
alias '?'=duck
alias '??'=google
alias '???'=bing
alias dot='cd $DOTFILES'
alias scripts='cd $SCRIPTS'
alias snippets='cd $SNIPPETS'
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
  done < "$envfile"
} && export -f envx

[[ -e "$HOME/.env" ]] && envx "$HOME/.env"

new-from() { 
  local template="$1"
  local name="$2"
  ! _have gh && echo "gh command not found" && return 1
  [[ -z "$name" ]] && echo "usage: $0 <name>" && return 1
  [[ -z "$GHREPOS" ]] && echo "GHREPOS not set" && return 1
  [[ ! -d "$GHREPOS" ]] && echo "Not found: $GHREPOS" && return 1
  cd "$GHREPOS" || return 1
  [[ -e "$name" ]] && echo "exists: $name" && return 1
  gh repo create -p "$template" "$name"
  cd "$name" || return 1
}

new-cmdbox() { new-from rwxrob/template-cmdbox "cmdbox-$1"; }
new-cmd() { new-from rwxrob/template-bash-command "cmd-$1"; }
cdz () { cd $(zet get "$@"); }

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
