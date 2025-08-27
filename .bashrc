# -------------------------------------------------
# Source global definitions
if [ -f /etc/bashrc ]; then
  source /etc/bashrc
fi

# -------------------------------------------------
# prompt color set
RESET=$(tput sgr0)
DARK_GRAY=$(tput setaf 0)
GREEN=$(tput setaf 2)
ORANGE=$(tput setaf 3)
MAGENTA=$(tput setaf 5)

# -------------------------------------------------
# common os environment settings
TERM=xterm-color
PS1='[\u@\h \W]\$ '
OSTYPE=`uname`
HISTTIMEFORMAT='%Y-%m-%d %T '
HISTSIZE=10000
TERM=xterm-256color

# -------------------------------------------------
# set alias
alias grep='grep -E --color=auto'
alias vi='vim'

# -------------------------------------------------
# import

# add git repository name in PS1
if [ -a $HOME/.git-completion.bash ]; then
  source $HOME/.git-completion.bash
fi

# -------------------------------------------------
# etc

# tmux start
if [ -z "$TMUX" -a -z "$STY" ]; then
    if type tmuxx >/dev/null 2>&1; then
        tmuxx
    elif type tmux >/dev/null 2>&1; then
        if tmux has-session && tmux list-sessions | /usr/bin/grep -qE '.*]$'; then
            tmux attach && echo "tmux attached session "
        else
            tmux new-session && echo "tmux created new session"
        fi
    elif type screen >/dev/null 2>&1; then
        screen -rx || screen -D -RR
    fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/Users/ikegami/.sdkman"
[[ -s "/Users/ikegami/.sdkman/bin/sdkman-init.sh" ]] && source "/Users/ikegami/.sdkman/bin/sdkman-init.sh"

. "$HOME/.local/bin/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/sumik/.lmstudio/bin"
# End of LM Studio CLI section

