# Setup fzf
# ---------
if [[ ! "$PATH" == */home/anpryl/.fzf/bin* ]]; then
  export PATH="$PATH:/home/anpryl/.fzf/bin"
fi

# Auto-completion
# ---------------
# [[ $- == *i* ]] && source "/home/anpryl/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/anpryl/.fzf/shell/key-bindings.zsh"

