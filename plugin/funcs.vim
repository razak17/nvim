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

nnoremap <silent> <Leader>d  :call <SID>DellThisBuf()<CR>
nnoremap <silent> <Leader>bdA :call <SID>DellAllBuf()<CR> :q!<CR>
nnoremap <silent> <Leader>bdh :call <SID>DelToLeft()<CR>
nnoremap <silent> <Leader>bdx :call <SID>DelAllExcept()<CR>
