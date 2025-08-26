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

alias ll='ls -vl'
alias greps='rg --hidden -p'
alias claude='claude --dangerously-skip-permissions'

# -------------------------------------------------
# user environment

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
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"


if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

path=(
  /Applications/TeXLive/Library/texlive
  /Applications/TeXLive/Library/mactexaddons
  $HOME/dotfiles/bin             # original dotfiles bin
  $HOME/.cabal/bin               # haskel package manager
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /opt/homebrew/share/google-cloud-sdk/path.zsh.inc
  /usr/local/heroku/bin(N-/)     # heroku toolbelt
  /usr/local/bin
  /usr/local/sbin
  /usr/local/share/zsh/site-functions(N-/)
  /usr/local/opt/avr-gcc@7/bin(N-/)
  /opt/homebrew/opt/coreutils/libexec/gnubin(N-/)
  /opt/homebrew/opt/llvm/bin(N-/)
  /opt/homebrew/opt/trash/bin(N-/)
  /Library/TeX/texbin(N-/)
  /opt/homebrew/opt/postgresql@15/bin(N-/)
  ~/.lmstudio/bin(N-/)
  $path
)
# /Library/TeX/texbin(N-/)

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
zplug "plugins/git", from:oh-my-zsh
zplug "woefe/git-prompt.zsh"
zplug "mafredri/zsh-async", from:github
# for MacOS
zplug "modules/osx", from:prezto, if:"[[ $OSTYPE == *darwin* ]]"
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "spaceship-prompt/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug 'sobolevn/wakatime-zsh-plugin'

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


# for compile keyboard1
export LDFLAGS="-L/usr/local/opt/avr-gcc@7/lib"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Google Cloud SDK
source  /opt/homebrew/share/google-cloud-sdk/completion.zsh.inc

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

autoload -U +X bashcompinit && bashcompinit

if [ -f /opt/homebrew/bin/terraform ]; then
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

zstyle ':completion:*' menu select
fpath+=~/.zfunc

complete -o nospace -C /opt/homebrew/Cellar/tfenv/3.0.0/versions/1.3.7/terraform terraform

eval "$(mise activate zsh --shims)"
if command -v starship &> /dev/null; then
  eval "$(starship completions zsh)"
  eval "$(starship init zsh)"
fi

# Added by Windsurf
export PATH="/Users/shivase/.codeium/windsurf/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/shivase/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

PYENV_VIRTUALENV_DISABLE_PROMPT=1

unction set_aws_profile() {
  # Select AWS PROFILE
  local selected_profile=$(aws configure list-profiles |
    grep -v "default" |
    sort |
    fzf --prompt "Select PROFILE. If press Ctrl-C, unset PROFILE. > " \
        --height 50% --layout=reverse --border --preview-window 'right:50%' \
        --preview "grep {} -A5 ~/.aws/config")

  # If the profile is not selected, unset the environment variable 'AWS_PROFILE', etc.
  if [ -z "$selected_profile" ]; then
    echo "Unset env 'AWS_PROFILE'!"
    unset AWS_PROFILE
    unset AWS_ACCESS_KEY_ID
    unset AWS_SECRET_ACCESS_KEY
    return
  fi

  # If a profile is selected, set the environment variable 'AWS_PROFILE'.
  echo "Set the environment variable 'AWS_PROFILE' to '${selected_profile}'!"
  export AWS_PROFILE="$selected_profile"
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY

  # Check sso-session
  local AWS_SSO_SESSION_NAME="your 'sso-session' name"  # sso-sessionの名称に変更

  check_sso_session=$(aws sts get-caller-identity 2>&1)
  if [[ "$check_sso_session" == *"Token has expired"* ]]; then
    # If the session has expired, log in again.
    echo -e "\n----------------------------\nYour Session has expired! Please login...\n----------------------------\n"
    aws sso login --sso-session "${AWS_SSO_SESSION_NAME}"
    aws sts get-caller-identity
  else
    # Display account information upon successful login, and show an error message upon login failure.
    echo ${check_sso_session}
  fi
}

alias brew="arch -arm64 brew"

. "$HOME/.local/bin/env"

# wakatime
export ZSH_WAKATIME_PROJECT_DETECTION=true

#############################################
# git auto status
#############################################

gitPreAutoStatusCommands=(
  'add'
  'rm'
  'reset'
  'commit'
  'checkout'
  'mv'
  'init'
)

function elementInArray() {
  local e
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
  return 1
}

function git() {
  command git $@

  if (elementInArray $1 $gitPreAutoStatusCommands); then
    command git status
  fi
}

#############################################
# Homebrew 版 trash を優先
#############################################

# rm: -r がある時だけディレクトリ許可、ない時はファイル限定
rm () {
  local recursive=false
  local targets=()

  # 引数を解析
  for arg in "$@"; do
    case "$arg" in
      -r|-rf|-fr) recursive=true ;;               # 再帰フラグ
      --) shift; targets+=("$@"); break ;;        # -- 以降は全部パス
      -*) echo "rm: 未対応オプション $arg" >&2; return 1 ;;
      *)  targets+=("$arg") ;;
    esac
  done

  [[ ${#targets[@]} -eq 0 ]] && {
    echo "rm: 削除対象が指定されていません" >&2
    return 1
  }

  # 判定と実行
  if $recursive; then
    # -r 付き → すべてディレクトリ想定
    for p in "${targets[@]}"; do
      [[ -d "$p" ]] || {
        echo "⚠️  '$p' はディレクトリではありません (-r 不要)" >&2
        return 1
      }
    done
    /opt/homebrew/opt/trash/bin/trash -F -- "${targets[@]}"
  else
    # -r なし → すべてファイル想定
    for p in "${targets[@]}"; do
      [[ -f "$p" ]] || {
        echo "⚠️  '$p' はファイルではありません。フォルダを消す場合は -r を付けてください。" >&2
        return 1
      }
    done
    /opt/homebrew/opt/trash/bin/trash -- "${targets[@]}"
  fi
}

# =================================================
# 環境別設定ファイルの読み込み（最後に読み込んで最優先）
# =================================================
# 優先順位（後から読み込まれるものが優先）:
# 1. .zshrc.local   - ローカル環境固有の設定
# 2. .zshrc.work    - 仕事環境用の設定
# 3. .zshrc.home    - 自宅環境用の設定
# 4. .zshrc.private - プライベートな設定（gitignoreに追加推奨）
# 5. .zshrc.$(hostname -s) - ホスト名固有の設定

# ベースとなる環境別設定
for env_file in local work home private; do
  if [ -f "$HOME/.zshrc.$env_file" ]; then
    source "$HOME/.zshrc.$env_file"
    # デバッグ用（必要に応じてコメントアウト）
    # echo "Loaded: .zshrc.$env_file"
  fi
done

# ホスト名ベースの設定（最優先）
HOST_CONFIG="$HOME/.zshrc.$(hostname -s)"
if [ -f "$HOST_CONFIG" ]; then
  source "$HOST_CONFIG"
  # デバッグ用（必要に応じてコメントアウト）
  # echo "Loaded: .zshrc.$(hostname -s)"
fi

# プロジェクト固有の設定（カレントディレクトリに.envrcがある場合）
# direnvを使用している場合は、direnvに任せる
if ! command -v direnv &> /dev/null && [ -f "./.envrc" ]; then
  source "./.envrc"
fi

