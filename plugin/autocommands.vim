fun! s:buf_filt(inc_cur)
  fun! s:filt_fn(include_current, idx, val)
    if !bufexists(a:val) ||
    \ !buflisted(a:val) ||
    \ buffer_name(a:val) =~? 'nvim_tree_*' ||
    \ (a:include_current && bufnr() == a:val)
      return v:false
    endif
    return v:true
  endfunction
  return filter(range(1, bufnr('$')), function('s:filt_fn', [a:inc_cur]))
endfunction

fun! s:DellAllBuf()
  wall
  silent execute 'bdelete ' . join(s:buf_filt(0))
endfunction

fun! s:DellThisBuf()
  update
  bprevious | split | bnext | bdelete
endfunction

" Delete buffers except current
fun! s:DelAllExcept()
  wall
  silent execute 'bdelete' join(s:buf_filt(1))
endfunction

" TODO
fun! s:DelToLeft()
  silent execute 'bdelete' join(range(1, bufnr() - 1))
endfunction

fun RevStr(str)
  let l:chars = split(submatch(0), '\zs')
  return join(reverse(l:chars), '')
endfunction

function s:should_show_cursorline() abort
  return &buftype !=? 'terminal' && empty(&winhighlight) && &ft != ''
endfunction

function! s:goto_line()
  let tokens = split(expand('%'), ':')
  if len(tokens) <= 1 || !filereadable(tokens[0])
    return
  endif

  let file = tokens[0]
  let rest = map(tokens[1:], 'str2nr(v:val)')
  let line = get(rest, 0, 1)
  let col  = get(rest, 1, 1)
  bd!
  silent execute 'e' file
  execute printf('normal! %dG%d|', line, col)
endfunction

if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
endif

vnoremap <Leader>rev :s/\%V.\+\%V./\=RevStr(submatch(0))<CR>gv
nnoremap <silent> <Leader><Leader>  :call <SID>DellThisBuf()<CR>
nnoremap <silent> <Leader>bdA :call <SID>DellAllBuf()<CR> :q!<CR>
nnoremap <silent> <Leader>bdh :call <SID>DelToLeft()<CR>
nnoremap <silent> <Leader>bdx :call <SID>DelAllExcept()<CR>

augroup Cursorline
  autocmd!
  " autocmd BufEnter * if s:should_show_cursorline() | setlocal cursorline | endif
  autocmd InsertEnter * if &ft != 'dashboard' | setlocal nocursorline | endif
  autocmd InsertLeave * if &ft != 'dashboard' | setlocal cursorline | endif
augroup END

augroup GoToLine
  au!
  autocmd! BufRead * nested call s:goto_line()
augroup END

augroup CustomWindowSettings
  autocmd!
  " These overrides should apply to all buffers
  autocmd WinEnter,WinNew * if &previewwindow
        \ | setlocal nospell concealcursor=nv nocursorline colorcolumn=
        \ | endif
augroup END


let s:save_excluded = ['lua.luapad']
function s:can_save() abort
  return empty(&buftype)
        \ && !empty(&filetype)
        \ && &modifiable
        \ && index(s:save_excluded, &ft) == -1
endfunction

augroup Utilities "{{{1
  autocmd!
  " source: https://vim.fandom.com/wiki/Use_gf_to_open_a_file_via_its_URL
  autocmd BufReadCmd file:///* exe "bd!|edit ".substitute(expand("<afile>"),"file:/*","","")
  " When editing a file, always jump to the last known cursor position.
  " Don't do it for commit messages, when the position is invalid, or when
  " inside an event handler (happens when dropping a file on gvim).
  autocmd BufReadPost *
        \ if &ft != 'gitcommit' && line("'\"") > 0 && line("'\"") <= line("$") |
        \   exe "keepjumps normal g`\"" |
        \ endif

  autocmd FileType gitcommit,gitrebase set bufhidden=delete
  autocmd BufWritePre,FileWritePre * silent! call mkdir(expand('<afile>:p:h'), 'p')

  " Save a buffer when we leave it
  autocmd BufLeave * if s:can_save() | silent! update | endif

  " Update filetype on save if empty
  autocmd BufWritePost * nested
        \ if &l:filetype ==# '' || exists('b:ftdetect')
        \ |   unlet! b:ftdetect
        \ |   filetype detect
        \ |   echom 'Filetype set to ' . &ft
        \ | endif

  autocmd Syntax * if 5000 < line('$') | syntax sync minlines=200 | endif
augroup END
