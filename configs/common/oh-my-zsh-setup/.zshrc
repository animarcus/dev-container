# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Oh My Zsh Configuration
#
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    colored-man-pages
    safe-paste
    history-substring-search
    common-aliases
    fast-syntax-highlighting
)

#
# Environment Setup
#
# Path configuration
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Terminal settings
export TERM="xterm-256color"
export CLICOLOR=1
export COLORTERM=truecolor

# Set editor
export EDITOR=vim

#
# Color Configuration
#
# Setup dircolors if available
if [ -f /etc/DIR_COLORS ]; then
    eval $(dircolors -b /etc/DIR_COLORS)
fi

# LS colors
export LSCOLORS=ExFxBxDxCxegedabagacad
eval "$(dircolors -b)" 2>/dev/null || export LSCOLORS=ExFxBxDxCxegedabagacad

#
# ZSH Specific Settings
#
# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Completion settings
zstyle ':completion:*' verbose yes
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-max 20
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#
# Key Bindings
#
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

#
# Aliases
#
alias ls='ls --color=auto -Fh'
alias ..='cd ..'
alias ...='cd ../..'
alias zr='source ~/.zshrc'

# Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
