setlocal autoindent
setlocal conceallevel=0
setlocal foldmethod=syntax
setlocal formatoptions=tcq2l
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal tabstop=2

let s:bufname = expand('%:e')
if s:bufname && s:bufname ==# 'jsonschema'
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal tabstop=2
endif

  " json 5 comment
syntax region Comment start="//" end="$" |
syntax region Comment start="/\*" end="\*/" |
setlocal commentstring=//\ %s
