if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
endif

" Binds
vnoremap <Leader>rev :s/\%V.\+\%V./\=RevStr(submatch(0))<CR>gv

" shake_case -> camelCase
nnoremap <silent> <Leader>Cc viw<Leader>cc
vnoremap <silent> <Leader>Cc :s/\%V_\(.\)/\U\1/g<CR>

" snake_case -> PascalCase
nnoremap <silent> <Leader>CP viw<Leader>CP
vnoremap <silent> <Leader>CP <Leader>cc`<vU

" camelCase/PascalCase -> snake_case
nmap <silent> <Leader>Cs viw<Leader>Cs
vnoremap <silent> <Leader>Cs :s/\%V\(\l\)\(\u\)/\1_\l\2/g<CR>`<vu

" TODO: implement
" snake_case -> kebab-case

