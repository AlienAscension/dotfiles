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

# Useful aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ls='lsd'
alias v='nvim'
alias cdg='cd ~/git'
alias update='sudo pacman -Syyu'
alias anyllm='~/AnythingLLMDesktop/start'

# Safer rm, cp, and mv
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'


# BLE SH (prompt enhancer — Starship still works with it)
source ~/.local/share/blesh/ble.sh

# Enable Starship
eval "$(starship init bash)"
