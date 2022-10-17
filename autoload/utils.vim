fun utils#rev_str(str)
  let l:chars = split(submatch(0), '\zs')
  return join(reverse(l:chars), '')
endfunction
