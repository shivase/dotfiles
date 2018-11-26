# standby modeに入る時間を1時間に変更
sudo pmset -a standbydelayhigh 3600
sudo pmset -a standbydelaylow 3600

# スクリーンショットの名前から日本語部分を削除
defaults write com.apple.screencapture name ""

# .DS_Storeファイルを作成しないようにする
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# クラッシュレポートの無効化
defaults write com.apple.CrashReporter DialogType -string "none"

# アプリケーション起動時のアニメーションを無効化
defaults write com.apple.dock launchanim -bool false

# Dashboard無効化
defaults write com.apple.dashboard mcx-disabled -bool true

## Finder

# アニメーションを無効化する
defaults write com.apple.finder DisableAllAnimations -bool true

# デフォルトで隠しファイルを表示する
defaults write com.apple.finder AppleShowAllFiles -bool true

# 全ての拡張子のファイルを表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# 名前で並べ替えを選択時にディレクトリを前に置くようにする
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# 検索時にデフォルトでカレントディレクトリを検索
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# ディスク検証を無効化
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes


## Spotlight

# トレイアイコンを非表示
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# メインディスクのインデックスの有効化
sudo mdutil -i on / > /dev/null

# インデックスの再構築
sudo mdutil -E / > /dev/null
