setlocal iskeyword+="
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

noremap <F10> :lua require 'internal.quickrun'.RunPython()<CR>
