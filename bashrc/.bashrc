# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Enable color support
if command -v dircolors &>/dev/null; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Kubernetes config
export KUBECONFIG=/home/linus/.kube/buero-tenant-linus.yaml
alias k='kubectl'


# Enable kubectl autocompletion
if command -v kubectl &>/dev/null; then
    source <(kubectl completion bash)
    complete -F __start_kubectl k
fi

# Kubernetes stuff
alias ctx='kubie ctx'

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


=======
# Git helper
alias gcm='git commit -m' # usage: gcm "message"

# System update
alias update='sudo pacman -Syyu'

# Local app launch
alias anyllm='~/AnythingLLMDesktop/start'


# Enable Starship prompt
eval "$(starship init bash)"
