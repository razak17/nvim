f (exists('b:did_ftplugin'))
  finish
endif
let b:did_ftplugin = 1

setlocal comments=:#
setlocal commentstring=#\ %s
setlocal formatoptions-=t
setlocal iskeyword+=$,@-@
setlocal softtabstop=2
setlocal shiftwidth=2
setlocal expandtab

let b:undo_ftplugin = 'setlocal com< cms< fo< isk< sts< sw< et<'
