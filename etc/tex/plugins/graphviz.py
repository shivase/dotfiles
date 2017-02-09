#!/usr/bin/env python

"""
Pandoc filter to process code blocks with class "graphviz" into
graphviz-generated images.
"""

import pygraphviz
import hashlib
import os
import sys
from pandocfilters import toJSONFilter, Str, Para, Image, RawInline
from subprocess import Popen, PIPE

def sha1(x):
  return hashlib.sha1(x.encode('utf-8')).hexdigest()

def cpp(code, filetype):
  p = Popen(['cpp', '-P', '-D_GRAPHVIZ_FILETYPE_%s' % filetype], \
            stdin=PIPE, stdout=PIPE)
  p.stdin.write(code.encode('utf-8'))
  p.stdin.close
  return p.communicate()[0].decode('utf-8')

imagedir = "graphviz-images"

def graphviz(key, value, format, meta):
  if key == 'CodeBlock':
    [[ident,classes,keyvals], code] = value
    dic = dict(keyvals)
    caption = "caption"
    if "graphviz" in classes:
      if format == "html":
        filetype = "png"
      elif format == "beamer":
        filetype = "pdf"
      elif format == "latex":
        filetype = "pdf"
      else:
        filetype = "png"
      G = pygraphviz.AGraph(string = cpp(code, filetype))
      G.layout()
      filename = sha1(code)
      alt = Str(caption)
      src = imagedir + '/' + filename + '.' + filetype
      if not os.path.isfile(src):
        try:
          os.mkdir(imagedir)
          sys.stderr.write('Created directory ' + imagedir + '\n')
        except OSError:
          pass
        G.draw(src,prog=('dot' if 'prog' not in dic else dic['prog']))
        sys.stderr.write('Created image ' + src + '\n')
      tit = ""
      if format in ['html','html5']:
        return Para([Image([alt], [src,tit])])
      else:
        width = dic['width'] if 'width' in dic else '0.5'
        height = dic['height'] if 'height' in dic else '0.5'
        #str = "\\includegraphics[width=%s\\maxwidth,height=%s\\maxheight]{%s}"
        str ="\\includegraphics[width=%s\\linewidth,height=%s\\textheight,keepaspectratio]{%s}" \
                % (width, height, src)
        return Para([RawInline("tex", str)])

if __name__ == "__main__":
  toJSONFilter(graphviz)
