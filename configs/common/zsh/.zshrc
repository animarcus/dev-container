# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# Powerlevel10k configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# PATH
export PATH=$HOME/bin:/usr/local/bin:$PATH
if [ -f /etc/DIR_COLORS ]; then
eval $(dircolors -b /etc/DIR_COLORS)
fi
# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
colored-man-pages
safe-paste
history-substring-search
common-aliases
# zsh-autocomplete
fast-syntax-highlighting
)
source $ZSH/oh-my-zsh.sh
zstyle ':completion:*' verbose yes
zstyle ':completion:*:messages' format '%d'
# Editor (set to nvim, since you'll install it)
export EDITOR=vim
# Aliases
alias ls='ls --color=auto -Fh'
alias ..='cd ..'
alias ...='cd ../..'
alias zr='source ~/.zshrc'
# nvim aliases
# Alias to start the Neovim container
alias nvim-start='cd /volume3/docker/docker-tools/neovim-ide && docker compose up -d'
# Alias to enter the Neovim container (Bash shell)
alias nvim-enter='docker exec -it nvim bash'
# Alias to stop the Neovim container
alias nvim-stop='cd /volume3/docker/docker-tools/neovim-ide && docker compose down'
# Alias to quickly edit your custom Neovim config (if you're using one)
alias nvim-config='vim /volume3/docker/docker-tools/neovim-ide/config/init.vim'
# Alias to open Neovim in the container, in the current directory
alias nvim-docker='docker exec -it nvim bash -c "cd /root/workspace/$(echo $PWD | sed '"'"'s|/volume3/docker||g'"'"') && nvim"'

# Key bindings
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ZSH Specific configurations
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-max 20
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# --- Optional: Disable Oh My Zsh auto-update prompting (uncomment ONE) ---
# zstyle ':omz:update' mode disabled  # Completely disable updates
# zstyle ':omz:update' mode auto     # Update automatically without asking
# zstyle ':omz:update' mode reminder # (Default) Just remind me to update

# Terminal color support
export TERM="xterm-256color"
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Force color support
export COLORTERM=truecolor

# LS_COLORS
eval "$(dircolors -b)" 2>/dev/null || export LSCOLORS=ExFxBxDxCxegedabagacad
