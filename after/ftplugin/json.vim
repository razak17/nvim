setlocal autoindent
setlocal conceallevel=0
setlocal foldmethod=syntax
setlocal formatoptions=tcq2l

  " json 5 comment
syntax region Comment start="//" end="$" |
syntax region Comment start="/\*" end="\*/" |
setlocal commentstring=//\ %s
