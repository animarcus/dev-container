# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =========
# Powerlevel10k configuration
# =========
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =========
# PATH
# =========
export PATH=$HOME/bin:/usr/local/bin:$PATH
export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
export PATH="$PATH:/Applications/IntelliJ IDEA.app/Contents/MacOS"

# =========
# Oh My Zsh
# =========

# Increase the maximum number of file descriptors
ulimit -n 10240

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    # General utilities
    colored-man-pages
    command-not-found
    safe-paste
    history-substring-search
    # rand-quote
    common-aliases

    # Development
    nmap
    python

    # User experience enhancements
    sudo
    zsh-autocomplete
    # zsh-syntax-highlighting
    fast-syntax-highlighting
    # autojump
)
source $ZSH/oh-my-zsh.sh

zstyle ':completion:*' verbose yes
zstyle ':completion:*:messages' format '%d'

# =========
# Editor
# =========
export EDITOR=code

# =========
# Aliases
# =========
alias ls='ls -GFh'
alias ..='cd ..'
alias ...='cd ../..'
alias zr='source ~/.zshrc'
alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
alias whisper-transcribe='/Users/marcushamelink/running-projects/scripts/transcribe/transcribe.sh'

alias comp-arch-pipeline-grid="$(cd /Users/marcushamelink/Developer/random-python-scripts/exec-diagram-creator && poetry env info -p)/bin/python /Users/marcushamelink/Developer/random-python-scripts/exec-diagram-creator/pipeline_grid.py"


# =========
# Key bindings
# =========
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


# =========
# NVM
# =========
export NVM_DIR=~/.nvm
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
if [ -f "$NVM_DIR/bash_completion" ]; then
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# =========
# SDK Man
# =========
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# =========
# SSH
# =========
# Add my keys to the ssh agent; passwords are pulled from the keychain.
# The --apple-load-keychain option is unique to MacOS.
ssh-add --apple-load-keychain >/dev/null 2>&1

# =========
# Functions
# =========
# Verible for Computer architecture CS-200 (Verilog utility)
verilator_docker() {
    docker run --rm -it \
        -v "$(pwd)":/work \
        -w /work \
        -u "$(id -u):$(id -g)" \
        verilator/verilator:latest \
        "$@"
}
alias verilator="verilator_docker"


# =========
# Other tools
# =========
# Pipx (Created by `pipx` on 2024-07-23 09:17:35)
export PATH="$PATH:/Users/marcushamelink/.local/bin"
autoload -U compinit && compinit
eval "$(register-python-argcomplete pipx)"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# Autojump tools
[ -f $HOMEBREW_PREFIX/etc/profile.d/autojump.sh ] && . $HOMEBREW_PREFIX/etc/profile.d/autojump.sh


# =========
# Completions
# =========
source <(ng completion script)  # Load Angular CLI autocompletion.

# =========
# ZSH Specific configurations
# =========

# Automatically list the first 10 suggestions without prompting
zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-max 20

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Uncomment the following line to enable command auto-correction.
# setopt CORRECT_ALL

# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


# =========
# New additions to this file
# =========

