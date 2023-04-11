# ディレクトリ名でcdを可能にする
setopt auto_cd
# 補完機能. 個別にOFFりたい場合は、 alias git="nocorrect git"とか無効に
# やっぱ邪魔なのでOFFる
unsetopt correct
# 補完時の表示をコンパクトにする
setopt list_packed

# ヒストリー定義
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
# ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
# 同じコマンドラインを連続で実行した場合はヒストリに登録しない。
setopt hist_ignore_dups
# スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
# すぐにヒストリファイルに追記する。
setopt inc_append_history
# zshプロセス間でヒストリを共有する。
setopt share_history
# C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control

# コマンドのオプションや引数を補完する
autoload -Uz compinit && compinit -u
# URLをエスケープする
autoload -Uz url-quote-magic
# VCS情報の表示を有効にする
autoload -Uz add-zsh-hook
#autoload -Uz vcs_info
# cdrを有効
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook

setopt prompt_subst

#zstyle ':vcs_info:*' formats '(%s)-[%b]'
#zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'

#function _update_vcs_info_msg() {
#  psvar=()
#  LANG=US.UTF-8 vcs_info
#  psvar[1]="$vcs_info_msg_0_"
#}
#
#add-zsh-hook precmd _update_vcs_info_msg
#RPROMPT="%v"

# 文字入力時にURLをエスケープする
zle -N self-insert url-quote-magic

# コマンド補完定義
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:cdr:*:*' menu selection
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-pushd true
zstyle ':filter-select:highlight' matched fg=yellow,standout
zstyle ':filter-select' case-insensitive yes
zstyle ':filter-select' extended-search yes

# -------------------------------------------------
# aliases

alias htop='sudo htop'

if (( ${+commands[vim]} )); then
  alias vi='vim'
fi

alias ls='exa'
alias ll='exa -l'
alias la='exa -a'
alias cat='bat'
alias greps='rg --hidden -p'

# -------------------------------------------------
# user environment

# for work environment ( override if needed )
if [ -f $HOME/.zshrc.work ]; then
  source $HOME/.zshrc.work
fi

# brew api token
if [ -f ~/.brew_api_token ];then
  source ~/.brew_api_token
fi

# set brew-file wrapper
if (( ${+commands[brew]} )); then
  if [ -f $(brew --prefix)/etc/brew-wrap ];then
    source $(brew --prefix)/etc/brew-wrap
  fi
fi

###################################################
# zsh plugins
###################################################

export ZPLUG_HOME=$HOME/.zplug
export CLICOLOR=1
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export GITHUB_URL=https://github.com/
source $ZPLUG_HOME/init.zsh
export GOPATH=$HOME/go
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"


if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

path=(
  $HOME/dotfiles/bin             # original dotfiles bin
  $HOME/.cabal/bin               # haskel package manager
  $HOME/.anyenv/bin              # anyenv(plenv,ndenv,rbenv...)
  $GOPATH/bin                    # Go
  /Library/TeX/texbin(N-/)
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/local/heroku/bin(N-/)     # heroku toolbelt
  /usr/local/bin
  /usr/local/sbin
  /usr/local/share/zsh/site-functions(N-/)
  /usr/local/opt/avr-gcc@7/bin(N-/)
  /opt/homebrew/opt/llvm/bin(N-/)
  $path
)

zplug 'zsh-users/zsh-autosuggestions'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'mollifier/anyframe'
zplug "mollifier/cd-gitroot"
zplug "mrowa44/emojify", as:command
zplug "b4b4r07/emoji-cli"
zplug "sorin-ionescu/prezto"
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "rupa/z", use:"*.sh"
zplug "wbingli/zsh-wakatime"
zplug "plugins/git", from:oh-my-zsh
zplug "woefe/git-prompt.zsh"
zplug "mafredri/zsh-async", from:github
zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
# for MacOS
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

if ! zplug check; then
  zplug install
fi

zplug load

#zplug load --verbose
bindkey -e

bindkey '^j^j' anyframe-widget-cdr
bindkey '^j^r' anyframe-widget-execute-history
bindkey '^j^g' anyframe-widget-cd-ghq-repository
bindkey '^j^t' anyframe-widget-tmux-attach

bindkey '^f' forward-word
bindkey '^b' backward-word
bindkey '^d' kill-wor

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'


# -------------------------------------------------
# zsh-completions

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
fi


# -------------------------------------------------
# anyenv
# https://github.com/riywo/anyenv

if [ -d $HOME/.anyenv ] ; then
    eval "$(anyenv init - zsh)"
fi

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# direnv hook
eval "$(direnv hook zsh)"

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

# for compile keyboard1
export LDFLAGS="-L/usr/local/opt/avr-gcc@7/lib"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

if [ -d $HOME/.anyenv ] ; then
    eval "$(anyenv init - zsh)"
fi

# Google Cloud SDK

if [ -d /opt/homebrew/Caskroom/google-cloud-sdk ]; then
    source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
    source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
fi

# -------------------------------------------------
# zsh pure theme settings
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit

prompt pure

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U +X bashcompinit && bashcompinit

if [ -f /opt/homebrew/bin/terraform ]; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

zstyle ':completion:*' menu select
fpath+=~/.zfunc
