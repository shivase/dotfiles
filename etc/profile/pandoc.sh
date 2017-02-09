# pandocに関するシェル関数を定義

# githubのcssを利用したhtmlを作成する
pandoc_html () {
  pandoc -s --self-contained -t html5 -c ~/.pandoc/github.css $@
}

# 日本語を含んだファイルをpdf化
pandoc_pdf () {
  local outName=`change_ext $1 pdf`
  pandoc -V documentclass=ltjarticle \
         --latex-engine=lualatex \
         -o ${outName} \
         $@
}

# TEST用PDF
# --variable classoption=twocolumn \
pandoc_test () {
  local outName=`change_ext $1 pdf`
  pandoc -V documentclass=ltjarticle \
         --latex-engine=lualatex \
         --listing \
         --number-sections \
         -H $HOME/dotfiles/etc/tex/template/list.tex \
         -fmarkdown-implicit_figures \
         --variable=geometry:a4paper,margin=2cm \
         -o ${outName} \
         $@
}

# 日本語を含んだファイルをpdf化(original版)
# marginとか色々いじってる
pandoc_note () {
    local outName=`change_ext $1 pdf`
    pandoc -V documentclass=ltjarticle \
           --latex-engine=lualatex \
           --listing \
           --number-sections \
           --variable=geometry:a4paper,margin=2cm \
           -H $HOME/dotfiles/etc/tex/template/header.tex \
           -fmarkdown-implicit_figures \
           -o ${outName} \
           $@
}

# pandocでslideshowを作成
# fontsize: 8pt, 9pt, 10pt, 11pt(default), 12pt, 14pt, 17pt, 20pt
pandoc_beamer () {
  local outName=`change_ext $1 pdf`
  pandoc --latex-engine=lualatex \
         -H $HOME/dotfiles/etc/tex/template/h-luatexja.tex \
         -t beamer \
         -V fontsize:14pt \
         -V theme=default \
         -V colortheme=beaver \
         --listing \
         --slide-level 1 \
         -fmarkdown-implicit_figures \
         -o ${outName} \
         $@
}

change_ext () {
    local fname_ext="${1##*/}"
    local fname="${fname_ext%.*}"
    echo "${fname}.$2"
}
