# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source dotfiles components
[ -f ~/.exports ] && source ~/.exports
[ -f ~/.aliases ] && source ~/.aliases  
[ -f ~/.functions ] && source ~/.functions

# Enable color support
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
fi

# History settings
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s dirspell
shopt -s globstar

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Kubernetes config (keep your existing setup)
export KUBECONFIG=/home/linus/.kube/buero-management.yaml

# Enable kubectl autocompletion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
fi

# Kubernetes stuff
alias ctx='kubie ctx'
alias k='kubectl'

# File listing aliases
alias ls='lsd -l'
alias lsa='lsd -la'
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Safer file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Editor & project directory
alias v='nvim'
alias cdg='cd ~/github/'  # change to ~/git if needed

# Git helper
alias gcm='git commit -m' # usage: gcm "message"

# System update
alias update='sudo pacman -Syyu'

# Local app launch
alias anyllm='~/AnythingLLMDesktop/start'

# FZF integration
if command -v fzf &>/dev/null; then
    eval "$(fzf --bash)"
fi

# Enable Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init bash)"
fi

# Load local bashrc if it exists
[ -f ~/.bashrc.local ] && source ~/.bashrc.local



### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/home/linus/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)


# Set Nvim as default editor
export EDITOR=nvim
export VISUAL=nvim

# Enable Krew Plugins for kubectl
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
