# 定義したオレオレショートカット一覧

## zsh関連

* z hoge<TAB> : ディレクトリ移動
* prefix ^j
 * ^j : anyframe-widget-cdr ディレクトリ移動
 * ^r : anyframe-widget-execute-history コマンド履歴
 * ^g : anyframe-widget-ghq-repository
 * ^p : zaw-process プロセス管理
 * ^s : zaw-sercher ディレクトリ内のag検索
* prefix ^v vagrant関連
 * ^v : anyframe-widget-vagrant vagrantホストの各種操作
 * ^j : anyframe-widget-vagrant-cdr vagrantホストのディレクトリに移動
* prefix ^g : git関連
 * ^s : zaw-git-status
 * ^f : zaw-git-files
 * ^b : zaw-git-branch

## vim関連

### previm

* F7  
  markdownをプレビュー

### color

* color設定をpreviewする  
  :Unite colorscheme -auto-preview

* color
 * :colorscheme splatoon
 * :colorscheme splatoon-1on1
 * :colorscheme splatoon-random

### NERDTree

* Ctrl-h : move to left tab
* Ctrl-l : move to right tab

### vim TAB(tab.vim)

* tc : tab生成
* tx : tab削除
* tn : tab next
* tp : tab previous
* t[1-9] : tab番号に移動

## zsh

* コマンドラインスタック  
  Ctrl-Q
* コマンドヒストリー(peco-select-history)
  Ctrl-r

## tmux
  * Ctrl-h : デフォルトキーバインド(ctrl-bが嫌だったので
  * r : .tmux.conf reload
  * Ctrl-tab or M-tab : window移動
  * Ctrl-m(M) : mouseモードのON/OFF
  * Ctrl-e(E) : synchronize-paneのON/FF
  * Shift+矢印 : pane移動
  * 矢印 : pane サイズ変更(連打可能

## tmuxinator

  * mux start work

## その他ショートカット等

### markdownのPDF/html可

* pandoc_html
```
$ pandoc_markdown hoge.markdown -o hoge.html
```
* pandoc_pdf
```
$ pandoc_pdf hoge.markdown -o hoge.pdf
```


