#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Editors
#

export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='ja_JP.UTF-8'
fi

#
# Paths
#

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

# Set the list of directories that Zsh searches for programs.
# (N-/): 存在しないディレクトリは登録しない。
path=(
  $HOME/dotfiles/bin(N-/)        # original dotfiles bin
  $HOME/.cabal/bin(N-/)          # haskel package manager
  $HOME/.anyenv/bin(N-/)         # anyenv(plenv,ndenv,rbenv...)
  /usr/texbin(N-/)               # tex
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /usr/local/heroku/bin(N-/)     # heroku toolbelt
  $path
)

# add anyenv pathes
if [ -d $HOME/.anyenv/envs ]; then
  for D in `ls $HOME/.anyenv/envs`
  do
      export PATH="$HOME/.anyenv/envs/$D/shims:$PATH"
  done
fi

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z-4'

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$LOGNAME"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"

# other export definitions
export GITHUB_URL=https://github.com/

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
  export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  export ANDROID_HOME='/usr/local/opt/android-sdk'
fi

# for maxtex
if [ -f /usr/libexec/path_helper ]; then
  eval `/usr/libexec/path_helper -s`
fi

# for HOMEBREW
export HOMEBREW_ANALYTICS_DEBUG=1
