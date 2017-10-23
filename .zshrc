# ディレクトリ名でcdを可能にする
setopt auto_cd
# 補完機能. 個別にOFFりたい場合は、 alias git="nocorrect git"とか無効に
# やっぱ邪魔なのでOFFる
unsetopt correct
# 補完時の表示をコンパクトにする
setopt list_packed

# ヒストリー定義
HISTFILE=~/.zsh_history
HISTSIZE=10000
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
autoload -Uz vcs_info
# cdrを有効
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook

setopt prompt_subst

zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'

function _update_vcs_info_msg() {
  psvar=()
  LANG=US.UTF-8 vcs_info
  psvar[1]="$vcs_info_msg_0_"
}

add-zsh-hook precmd _update_vcs_info_msg
RPROMPT="%v"

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
source ~/.zplug/init.zsh
zplug 'zsh-users/zsh-autosuggestions'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=250'

zplug 'zsh-users/zsh-syntax-highlighting', defer:2
zplug 'zsh-users/zsh-completions'
zplug 'mollifier/anyframe'
zplug "mollifier/cd-gitroot"
zplug "mrowa44/emojify", as:command
zplug "b4b4r07/emoji-cli"
zplug "stedolan/jq", from:gh-r, as:command
zplug "sorin-ionescu/prezto"
zplug "modules/prompt", from:prezto
# zstyle は zplug load の前に設定する
zstyle ':prezto:module:prompt' theme 'powerline'
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

bindkey '^f' forward-word
bindkey '^b' backward-word
bindkey '^d' kill-wor

export CLICOLOR=1
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'
export GITHUB_URL=https://github.com/
export ANDROID_HOME='/usr/local/opt/android-sdk'

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
  $path
)

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'
export JAVA_HOME=`/usr/libexec/java_home -v 1.8`

# -------------------------------------------------
# anyenv
# https://github.com/riywo/anyenv

if [ -d $HOME/.anyenv ] ; then
    eval "$(anyenv init - zsh)"
fi

# -------------------------------------------------
# my profiles

for rcfiles in $( ls $HOME/dotfiles/etc/profile/*.sh ); do
  source $rcfiles
done

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
