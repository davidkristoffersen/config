#!/bin/bash

# Navigation
# enable color support of ls and also add handy aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias tree='tree -C'

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias srcbash='source ~/.bashrc'
alias bashrc='vim ~/.bashrc'
alias bashconfig='vim -p ~/.bash*'
alias vimrc='vim $MYVIMRC'

alias c='clear'

# Program specific
alias ed_osucli='vim ~/scripts/osu/osucli.py'
alias rip='gio trash'
alias lock='i3lock-fancy -pf inconsolata'
alias python='python3'
alias pcloud_start='pcloud > /dev/null 2>&1 &'