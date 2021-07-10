fun! utils#message(msg, ...) abort
  let hl = 'WarningMsg'
  if a:0 " a:0 is the number of optional args provided
    let hl = a:1
  endif
  execute 'echohl '. hl
  echom a:msg
  echohl none
endfunction

fun! utils#buf_filt(inc_cur)
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

fun utils#RevStr(str)
  let l:chars = split(submatch(0), '\zs')
  return join(reverse(l:chars), '')
endfunction
