# Set up the prompt

autoload -Uz promptinit
promptinit

HISTFILE=~/.zsh_history
HISTSIZE=5800
SAVEHIST=5800

setopt appendhistory
setopt incappendhistory
setopt histignorealldups
unsetopt sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# prompt
autoload -Uz vcs_info
precmd() { vcs_info }
setopt prompt_subst

zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' (%b)'
zstyle ':vcs_info:git:*' actionformats ' (%b|%a)'
zstyle ':vcs_info:git:*' check-for-changes true

#prompt adam1
#PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f%F{yellow}${vcs_info_msg_0_}%f %F{green}%D{%H:%M}%f %# '

source $HOME/.env
