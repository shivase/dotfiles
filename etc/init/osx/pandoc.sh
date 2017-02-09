#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

e_newline
e_header "install pandoc and necessary files..."

# HomebrewではなくHaskelのパッケージ管理cabal
# pandocを利用して、markdownをPDF/html化するための準備
cabal update
cabal install cabal-install
cabal install pandoc

sudo tlmgr update --self
sudo tlmgr update --all
sudo tlmgr install collection-langjapanese collection-latexrecommended collection-fontsrecommended

e_done "pandoc install finished"
