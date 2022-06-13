let s:bufname = expand('%:e')

if s:bufname && s:bufname ==# 'jsonschema'
  setlocal shiftwidth=2
  setlocal softtabstop=2
  setlocal tabstop=4
endif
