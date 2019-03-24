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

autoload -Uz compinit && compinit -u
autoload -Uz url-quote-magic
autoload -Uz vcs_info
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook is-at-least

setopt prompt_subst

# git prompt設定
zstyle ':vcs_info:*' enable git svn hg
zstyle ':vcs_info:*' formats '(%s)[%b] '
zstyle ':vcs_info:*' actionformats '(%s)[%b|%a] '

if is-at-least 4.3.10; then
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"
  zstyle ':vcs_info:git:*' unstagedstr "-"
  zstyle ':vcs_info:git:*' formats '(%s)[%b]%c%u'
  zstyle ':vcs_info:git:*' actionformats '(%s)[%b|%a]%c%u'
fi

zstyle ':vcs_info:bzr:*' use-simple true

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
zstyle ':filter-select' case-insensitive yes
zstyle ':filter-select' extended-search yes

# -------------------------------------------------
# aliases

alias htop='sudo htop'

if (( ${+commands[vim]} )); then
  alias vi='vim'
fi

alias la='ls -a' # dot(.)で始まるディレクトリ、ファイルも表示
alias la='ls -al' # -a オプションと -l オプションの組み合わせ
alias ll='ls -lav'
alias ll='ls -l' # ファイルの詳細も表示
alias lla='ls -la' # -a オプションと -l オプションの組み合わせ
alias ls='ls -F' # ディレクトリ名の末尾にはスラッシュ、シンボリックリンクの末尾には@というように種類ごとの表示をつけてくれる
alias ls='ls -v -G' # Gはアウトプットに色を付けてくれる

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

export ZPLUG_HOME=/usr/local/opt/zplug
export CLICOLOR=1
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export GITHUB_URL=https://github.com/
export ANDROID_HOME='/usr/local/share/android-sdk'
source $ZPLUG_HOME/init.zsh
export GOPATH=$HOME/go

if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

path=(
  $HOME/dotfiles/bin             # original dotfiles bin
  $HOME/.cabal/bin               # haskel package manager
  $HOME/.anyenv/bin              # anyenv(plenv,ndenv,rbenv...)
  $GOPATH/bin                    # Go
  /Library/TeX/texbin(N-/)
  /usr/local/heroku/bin(N-/)     # heroku toolbelt
  /usr/local/bin
  /usr/local/sbin
  /usr/local/share/zsh/site-functions(N-/)
  /usr/local/opt/avr-gcc@7/bin(N-/)
  /usr/local/opt/mysql-client/bin(N-/)
  ./node_modules/.bin
  $ANDROID_HOME/tools
  $ANDROID_HOME/platform-tools
  $path
)

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

zplug 'zsh-users/zsh-autosuggestions'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=250'

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'zsh-users/zsh-completions'
zplug 'mollifier/anyframe'
zplug "mollifier/cd-gitroot"
zplug "mrowa44/emojify", as:command
zplug "b4b4r07/emoji-cli", if:"which jq"
zplug "stedolan/jq", from:gh-r, as:command
zplug "sorin-ionescu/prezto"
zplug "modules/prompt", from:prezto
# zstyle は zplug load の前に設定する
zstyle ':prezto:module:prompt' theme 'powerline'
zstyle ':prezto:module:prompt' pwd-length 'short'
zplug "junegunn/fzf-bin", \
      from:gh-r, \
      as:command, \
      rename-to:fzf, \
      use:"*darwin*amd64*"
zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
zplug "b4b4r07/enhancd", use:enhancd.sh
# Tracks your most used directories, based on 'frecency'.
zplug "rupa/z", use:"*.sh"
# for MacOS
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/git", from:oh-my-zsh

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

bindkey '^f' forward-char
bindkey '^b' backward-char
bindkey '^d' kill-wor

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# -------------------------------------------------
# anyenv
# https://github.com/riywo/anyenv

if [ -d $HOME/.anyenv ] ; then
    eval "$(anyenv init - zsh)"
fi

# -------------------------------------------------

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.docker-fzf-completion ] && source ~/.docker-fzf-completion
export DOCKER_BUILDKIT=1
export FZF_COMPLETION_TRIGGER="," # default: '**'

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

# -------------------------------------------------
# user functions
function history-all { history -E 1 }

# -------------------------------------------------
# kubernetes
if [ -d $HOME/.kube ] ; then
    KUBECONFIG=$HOME/.kube/config_st:$HOME/.kube/config_dev kubectl config view --flatten > ~/.kube/config
    export KUBECONFIG=$HOME/.kube/config
    source <(kubectl completion zsh)
    source <(stern --completion=zsh)
fi


# -------------------------------------------------
# AWS Command
alias awsp="source _awsp"
alias aws-whoami="aws sts get-caller-identity --output text --query Arn"
