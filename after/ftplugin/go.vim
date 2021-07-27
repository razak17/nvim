"---------------------------------------------------------------------------//
" GO FILE SETTINGS
""---------------------------------------------------------------------------//
setlocal noexpandtab
setlocal textwidth=100
setlocal iskeyword+="
setlocal shiftwidth=4
setlocal softtabstop=4
setlocal tabstop=4

" create a go doc comment based on the word under the cursor
function! s:create_go_doc_comment()
  norm "zyiw
  execute ":put! z"
  execute ":norm I// \<Esc>$"
endfunction
nnoremap <leader>cf :<C-u>call <SID>create_go_doc_comment()<CR>
