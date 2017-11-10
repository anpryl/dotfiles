export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/perl5/bin
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:~/.cabal/bin
export VISUAL=nvim
export EDITOR="$VISUAL"
export GIT_MERGE_AUTOEDIT=no

PATH="/home/anpryl/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/anpryl/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/anpryl/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/anpryl/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/anpryl/perl5"; export PERL_MM_OPT;

alias rcfg="source ~/.zshrc"
alias vim="nvim"
alias vst="nvim ~/apps/st-0.7/config.h"
alias vzsh="nvim ~/.zshrc"
alias vgit="nvim ~/.gitconfig"
alias vnvim="nvim ~/.config/nvim/init.vim"
alias vssh="nvim ~/.ssh/config"
alias dus="du -hs * | sort -hr"
alias dff='df -h'
alias duu='du -h --max-depth=1 | sort -h'
alias weather='http wttr.in'
alias a='sudo apt install'
alias au='sudo apt update && sudo apt upgrade'
alias ar='sudo apt autoremove'
alias ai='apt show'
alias as='apt search'
alias tgms='cd $GOPATH/src/gitlab.qarea.org/tgms'
alias stterm='cd ~/apps/st-0.7'
alias gopath='cd $GOPATH/src'
alias txa="tmux attach || tmux new"
alias edm='eval $(docker-machine env default)'
alias rac='docker rm -fv $(docker ps -a -q)'

alias haskgen='hasktags -c -x -R . ; codex update'
alias sbuild='stack build --fast --file-watch'

eval $(thefuck --alias)
eval `dircolors /home/anpryl/.dir_colors/dircolors`

stty -ixon

set -o vi

export FZF_DEFAULT_OPTS='--bind alt-j:down,alt-k:up'

export ZSH=/home/anpryl/.oh-my-zsh

ZSH_THEME="agnoster"

plugins=(zsh-completions commmon-aliases git cabal docker httpie jsontools systemd tmux vagrant vi-mode autoenv colorize colored-man-pages go stack git-open)

autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

export ZSH_TMUX_AUTOSTART=true

# export ZLE_PROMPT_INDENT=1

setopt autocd
setopt extended_glob
setopt extended_history
#setopt share_history
setopt inc_append_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt menucomplete

zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select
zstyle ':completion:*'            menu select=1 _complete _ignored _approximate

function zle-line-init () { echoti smkx }
function zle-line-finish () { echoti rmkx }
zle -N zle-line-init
zle -N zle-line-finish


_comp_options+=(globdots)
autoload -U compinit && compinit

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# cowsay -f tux $(fortune)
export PATH="/home/anpryl/.linuxbrew/bin:$PATH"
export MANPATH="/home/anpryl/.linuxbrew/share/man:$MANPATH"
export INFOPATH="/home/anpryl/.linuxbrew/share/info:$INFOPATH"

PROMPT="%{%f%b%k%}$(build_prompt)"$'\n'"$ "
