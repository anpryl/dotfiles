export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/perl5/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:~/.cabal/bin
export VISUAL=vim
export EDITOR=$VISUAL
export GIT_MERGE_AUTOEDIT=no
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

#PATH="/home/anpryl/perl5/bin${PATH:+:${PATH}}"; export PATH;
#PERL5LIB="/home/anpryl/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
#PERL_LOCAL_LIB_ROOT="/home/anpryl/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
#PERL_MB_OPT="--install_base \"/home/anpryl/perl5\""; export PERL_MB_OPT;
#PERL_MM_OPT="INSTALL_BASE=/home/anpryl/perl5"; export PERL_MM_OPT;

alias ls='ls --color=always'
alias dir='dir --color=always'
alias vdir='vdir --color=always'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias zcfg="source ~/.zshrc"
alias vzsh="nvim ~/.zshrc"
alias vgit="nvim ~/.gitconfig"
alias vnvim="nvim ~/.config/nvim/init.vim"
alias vssh="nvim ~/.ssh/config"
alias dus="du -hs * | sort -hr"
alias dff='df -h'
alias duu='du -h --max-depth=1 | sort -h'
alias weather='http wttr.in'
alias tgms='cd $GOPATH/src/gitlab.qarea.org/tgms'
alias gopath='cd $GOPATH/src'
alias rac='docker rm -fv $(docker ps -a -q)'
alias reboot="sudo systemctl reboot"
alias poweroff="sudo systemctl poweroff"
alias txa="tmux -2 attach || tmux -2 new"
alias halt="sudo halt"
alias mnix-env="nix-env -f https://github.com/NixOS/nixpkgs/archive/master.tar.gz"
alias haskgen='hasktags -c -x -R . ; codex update'
alias sbuild='stack build --fast --file-watch'

stty -ixon

set -o vi

export FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up'

autoload -U compinit && compinit

HISTFILE=~/.zhistory
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

export LANG=en_US.UTF-8

setopt autocd
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

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
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
_comp_options+=(globdots)

zmodload -a zsh/stat stat
zmodload -a zsh/zpty zpty
zmodload -a zsh/zprof zprof
zmodload -ap zsh/mapfile mapfile

function zle-line-init () { echoti smkx }
function zle-line-finish () { echoti rmkx }
zle -N zle-line-init
zle -N zle-line-finish

autoload -U compinit && compinit

export KEYTIMEOUT=1

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

eval `dircolors /home/anpryl/dircolors-solarized/dircolors.ansi-dark`

if [ "$TMUX" = "" ]; then txa; fi
 
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/completion.zsh"
  source "$(fzf-share)/key-bindings.zsh"
fi

PROMPT="%{%f%b%k%}$(build_prompt)"$'\n'"$ "
