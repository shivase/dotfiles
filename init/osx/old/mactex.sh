#!/bin/sh

. "$DOTPATH"/etc/lib/vital.sh

e_header "mactexのjapanese対応設定を実行します"

sudo tlmgr update --self --all
sudo tlmgr install collection-langjapanese latexmk
sudo tlmgr install framed wrapfig pdfcomment marginnote datetime fmtcount bezos collection-fontsrecommended filehook

if [ -d /usr/local/texlive/2015basic/texmf-dist/scripts/cjk-gs-integrate ]; then
  cd /usr/local/texlive/2015basic/texmf-dist/scripts/cjk-gs-integrate
  sudo perl cjk-gs-integrate.pl --link-texmf
  sudo mktexlsr
  sudo updmap-sys --setoption kanjiEmbed hiragino-elcapitan-pron
fi
