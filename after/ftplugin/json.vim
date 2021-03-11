setlocal autoindent
setlocal conceallevel=0
setlocal expandtab
setlocal foldmethod=syntax
setlocal formatoptions=tcq2l
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=8

let s:bufname = expand('%:e')
if s:bufname && s:bufname ==# 'jsonschema'
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal tabstop=4
endif

  " json 5 comment
syntax region Comment start="//" end="$" |
syntax region Comment start="/\*" end="\*/" |
setlocal commentstring=//\ %s
