#!/bin/bash

# custom
alias art='php artisan'
alias cm='cmatrix -axbslC cyan -u 1'

# tmux
alias tm='tmux -2'
alias tc='tm new -s'
alias ta='tm a'
alias tl='tm ls'

# aptitude
alias au='apt-get update'
alias as='aptitude search'
alias ai='apt-get install'
alias ag='apt-get upgrade'
alias ad='apt-get dist-upgrade'

# git
alias ga='git add * --all -f'
alias gc='git commit -a'
alias gp='git push origin master'
alias gr='git reset --hard'
alias gd='git diff'

export PS1="\[\e[0m\][\[\033[1;30m\]\d \T\[\e[0m\]] \[\e[0m\]\[\e[0;92m\]\u@\h\[\e[0m\]:\[\e[0;94m\]\w\[\033[1;30m\] ($(if [[ $? == 0 ]]; then echo "\[\e[0;92m\]\342\234\223\[\e[0m\]"; else echo "\[\e[0;91m\]\342\234\227\[\e[0m\]"; fi)\[\033[1;30m\])\[\e[0m\] $ "
