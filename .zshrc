export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/perl5/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:~/.cabal/bin
export VISUAL=nvim
export EDITOR=$VISUAL
export GIT_MERGE_AUTOEDIT=no

#PATH="/home/anpryl/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="/home/anpryl/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/anpryl/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/anpryl/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/anpryl/perl5"; export PERL_MM_OPT;

alias rcfg="source ~/.zshrc"
alias vst="nvim ~/apps/st-0.7/config.h"
alias vzsh="nvim ~/.zshrc"
alias vgit="nvim ~/.gitconfig"
alias vnvim="nvim ~/.config/nvim/init.vim"
alias vssh="nvim ~/.ssh/config"
alias dus="du -hs * | sort -hr"
alias dff='df -h'
alias duu='du -h --max-depth=1 | sort -h'
alias weather='curl wttr.in'
alias a='sudo apt install'
alias au='sudo apt update && sudo apt upgrade'
alias ar='sudo apt autoremove'
alias ai='apt show'
alias as='apt search'
alias tgms='cd $GOPATH/src/gitlab.qarea.org/tgms'
alias stterm='cd ~/apps/st-0.7'
alias gopath='cd $GOPATH/src'
alias edm='eval $(docker-machine env default)'
alias rac='docker rm -fv $(docker ps -a -q)'
alias reboot="sudo reboot"
alias txa="tmux -2 attach || tmux -2 new"
alias halt="sudo halt"
alias mnix-env="nix-env -f https://github.com/NixOS/nixpkgs/archive/master.tar.gz"
alias haskgen='hasktags -c -x -R . ; codex update'
alias sbuild='stack build --fast --file-watch'

eval `dircolors /home/anpryl/.dir_colors/dircolors`

stty -ixon

set -o vi

export FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up'

autoload -U compinit && compinit

HISTFILE=~/.zhistory
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

export LANG=en_US.UTF-8

export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOCONNECT=true

setopt extended_glob
setopt extended_history
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt menucomplete
setopt APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt NO_BEEP
setopt AUTO_CD
setopt CORRECT_ALL
setopt histexpiredupsfirst histfindnodups
setopt histignoredups histnostore histverify histignorespace extended_history
setopt notify globdots correct pushdtohome cdablevars autolist
setopt correctall autocd recexact longlistjobs
setopt autoresume histignoredups pushdsilent noclobber
setopt autopushd pushdminus extendedglob rcquotes mailwarning
unsetopt bgnice autoparamslash

setopt  IGNORE_EOF
typeset -U path cdpath fpath manpath
autoload colors && colors

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select
zstyle ':completion:*'            menu select=1 _complete _ignored _approximate
zstyle ':completion:*::::' completer _expand _complete _ignored _approximate
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns '*?.o' '*?.c~''*?.old' '*?.pro'
zstyle ':completion:*:functions' ignored-patterns '_*'

zstyle ':completion:*' menu yes select

zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

function zle-line-init () { echoti smkx }
function zle-line-finish () { echoti rmkx }
zle -N zle-line-init
zle -N zle-line-finish

_comp_options+=(globdots)
autoload -U compinit && compinit

zstyle :compinstall filename '/home/anpryl/.zshrc'

export KEYTIMEOUT=1

eval "$(direnv hook zsh)"

mkcd(){ mkdir $1; cd $1 }

extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       unrar x $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "Unknown filetype '$1'..." ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

pk () {
    if [ $1 ] ; then
        case $1 in
            tbz)       tar cjvf $2.tar.bz2 $2      ;;
            tgz)       tar czvf $2.tar.gz  $2       ;;
            tar)       tar cpvf $2.tar  $2       ;;
            bz2)       bzip2 $2 ;;
            gz)        gzip -c -9 -n $2 > $2.gz ;;
            zip)       zip -r $2.zip $2   ;;
            7z)        7z a $2.7z $2    ;;
            *)         echo "'$1' cannot be packed via pk()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# fkill - kill process
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]
  then
    echo $pid | xargs kill -${1:-9}
  fi
}

# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}

if ! declare -f _fzf_compgen_path > /dev/null; then
  _fzf_compgen_path() {
    echo "$1"
    command find -L "$1" \
      -name .git -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

if ! declare -f _fzf_compgen_dir > /dev/null; then
  _fzf_compgen_dir() {
    command find -L "$1" \
      -name .git -prune -o -name .svn -prune -o -type d \
      -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
  }
fi

###########################################################

__fzfcmd_complete() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fzf_generic_path_completion() {
  local base lbuf compgen fzf_opts suffix tail fzf dir leftover matches
  # (Q) flag removes a quoting level: "foo\ bar" => "foo bar"
  base=${(Q)1}
  lbuf=$2
  compgen=$3
  fzf_opts=$4
  suffix=$5
  tail=$6
  fzf="$(__fzfcmd_complete)"

  setopt localoptions nonomatch
  dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${~dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      dir=${~dir}
      matches=$(eval "$compgen $(printf %q "$dir")" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS" ${=fzf} ${=fzf_opts} -q "$leftover" | while read item; do
        echo -n "${(q)item}$suffix "
      done)
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle redisplay
      typeset -f zle-line-init >/dev/null && zle zle-line-init
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_fzf_path_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_path \
    "-m" "" " "
}

_fzf_dir_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_dir \
    "" "/" ""
}

_fzf_feed_fifo() (
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &
)

_fzf_complete() {
  local fifo fzf_opts lbuf fzf matches post
  fifo="${TMPDIR:-/tmp}/fzf-complete-fifo-$$"
  fzf_opts=$1
  lbuf=$2
  post="${funcstack[2]}_post"
  type $post > /dev/null 2>&1 || post=cat

  fzf="$(__fzfcmd_complete)"

  _fzf_feed_fifo "$fifo"
  matches=$(cat "$fifo" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS" ${=fzf} ${=fzf_opts} -q "${(Q)prefix}" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  command rm -f "$fifo"
}

_fzf_complete_telnet() {
  _fzf_complete '+m' "$@" < <(
    command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0' |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_fzf_complete_ssh() {
  _fzf_complete '+m' "$@" < <(
    command cat <(cat ~/.ssh/config /etc/ssh/ssh_config 2> /dev/null | command grep -i '^host' | command grep -v '*') \
        <(command grep -oE '^[a-z0-9.,:-]+' ~/.ssh/known_hosts | tr ',' '\n' | awk '{ print $1 " " $1 }') \
        <(command grep -v '^\s*\(#\|$\)' /etc/hosts | command grep -Fv '0.0.0.0') |
        awk '{if (length($2) > 0) {print $2}}' | sort -u
  )
}

_fzf_complete_export() {
  _fzf_complete '-m' "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unset() {
  _fzf_complete '-m' "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unalias() {
  _fzf_complete '+m' "$@" < <(
    alias | sed 's/=.*//'
  )
}

fzf-completion() {
  local tokens cmd prefix trigger tail fzf matches lbuf d_cmds
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  cmd=${tokens[1]}

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [ -z "$trigger" -a ${LBUFFER[-1]} = ' ' ] && tokens+=("")

  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}
  # Kill completion (do not require trigger sequence)
  if [ $cmd = kill -a ${LBUFFER[-1]} = ' ' ]; then
    fzf="$(__fzfcmd_complete)"
    matches=$(ps -ef | sed 1d | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-50%} --min-height 15 --reverse $FZF_DEFAULT_OPTS --preview 'echo {}' --preview-window down:3:wrap $FZF_COMPLETION_OPTS" ${=fzf} -m | awk '{print $2}' | tr '\n' ' ')
    if [ -n "$matches" ]; then
      LBUFFER="$LBUFFER$matches"
    fi
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  # Trigger sequence given
  elif [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS:-cd pushd rmdir})

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    [ -z "${tokens[-1]}" ] && lbuf=$LBUFFER        || lbuf=${LBUFFER:0:-${#tokens[-1]}}

    if eval "type _fzf_complete_${cmd} > /dev/null"; then
      eval "prefix=\"$prefix\" _fzf_complete_${cmd} \"$lbuf\""
    elif [ ${d_cmds[(i)$cmd]} -le ${#d_cmds} ]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}

[ -z "$fzf_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fzf_default_completion=$binding[(s: :w)2]
  unset binding
}

zle     -N   fzf-completion
bindkey '^I' fzf-completion

if [[ $- == *i* ]]; then

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  local ret=$?
  zle reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null
  selected=( $(fc -l 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS --tac -n2..,.. --tiebreak=index --bind=ctrl-r:toggle-sort $FZF_CTRL_R_OPTS --query=${(q)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

fi

if [ "$TMUX" = "" ]; then txa; fi

PROMPT="%{%f%b%k%}$(build_prompt)"$'\n'"$ "
