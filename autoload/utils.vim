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

fun utils#rev_str(str)
  let l:chars = split(submatch(0), '\zs')
  return join(reverse(l:chars), '')
endfunction

let g:presentationBoundsDisplayed = 0
fun! utils#display_presentation_boundaries()
  if g:presentationBoundsDisplayed
    match
    set colorcolumn=0
    let g:presentationBoundsDisplayed = 0
  else
    highlight lastoflines ctermbg=darkred guibg=darkred
    match lastoflines /\%23l/
    set colorcolumn=105
    let g:presentationBoundsDisplayed = 1
  endif
endfunction

fun! utils#find_execute_command()
  let line = search('\S*!'.'!:.*')
  if line > 0
    let command = substitute(getline(line), "\S*!"."!:*", "", "")
    execute "silent !". command
    execute "normal gg0"
    redraw
  endif
endfunction

fun! utils#list_folds()
  let thisline = getline(v:lnum)
  if match(thisline, '^- ') >= 0
    return ">1"
  elseif match(thisline, '^  - ') >= 0
    return ">2"
  elseif match(thisline, '^    - ') >= 0
    return ">3"
  elseif match(thisline, '^      - ') >= 0
    return ">4"
  elseif match(thisline, '^        - ') >= 0
    return ">5"
  endif
  return "0"
endfunction


fun utils#simple_fold_text()
  let line = getline(v:foldstart)
  let sub = substitute(line, '/\*\|\*/\|{{{\d\=', '', 'g')
  return sub . ' >>>>>>'
endfunction
