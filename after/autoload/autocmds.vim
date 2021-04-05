fun! autocmds#TrimWhitespace()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfun

fun! autocmds#EmptyRegisters()
  let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
  for r in regs
      call setreg(r, [])
  endfor
endfun

fun! autocmds#RunPython()
  let s:current_file = expand("%")
  enew|silent execute ".!python " . shellescape(s:current_file, 1)
  setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
  setlocal nobuflisted
endfun
