" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

runtime! syntax/log.vim
let b:current_syntax = "dap-repl"

" Add autocompletion
lua require('dap.ext.autocompl').attach()


function! s:adjust_height(minheight, maxheight)
  exe max([min([line("$"), a:maxheight]), a:minheight]) . "wincmd _"
endfunction

setlocal nobuflisted " quickfix buffers should not pop up when doing :bn or :bp
call s:adjust_height(10, 15)
