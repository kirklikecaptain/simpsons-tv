# ~/.bashrc: executed by bash(1) for non-login shells.

# if [ "$(fgconsole 2>/dev/null)" != "1" ]; then
#     sudo chvt 1
# fi


# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Clear screen on local TTY sessions only
# if [ -z "$SSH_CONNECTION" ] && [ -z "$SSH_CLIENT" ]; then
#     clear
# fi

# Enable blinking cursor on tty2-6, keep hidden on tty1
# case $(tty) in
#     /dev/tty[2-6]) setterm -cursor on -blink on ;;
# esac

# History settings
HISTCONTROL=ignoreboth
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Update window size after each command
shopt -s checkwinsize

# Chroot identification
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Colored prompt with TTY display on local sessions
C_RESET='\[\033[00m\]'
C_GREEN='\[\033[01;32m\]'
C_CYAN='\[\033[01;36m\]'
C_MAGENTA='\[\033[01;35m\]'
C_BLUE='\[\033[01;34m\]'
C_GOLD='\[\033[00;33m\]'

# Build prompt components
PS1_CHROOT="${debian_chroot:+($debian_chroot)}"
PS1_USER="${C_GREEN}\u${C_RESET}"
PS1_HOST="${C_CYAN}\h${C_RESET}"
PS1_LOCATION='$(if [ -z "$SSH_CONNECTION" ]; then echo "[\l]"; else echo "[ssh]"; fi)'
PS1_MARK="${C_BLUE}\w \$ ${C_RESET}"

# Assemble final prompt: host user [tty/ssh] dirname $
PS1="${PS1_CHROOT}${PS1_USER} @ ${PS1_HOST} ${PS1_LOCATION} ${PS1_MARK}"

# Set xterm title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# Enable color support for ls and grep
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Load bash aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Enable bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi