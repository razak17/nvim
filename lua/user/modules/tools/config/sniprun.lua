return function()
  local P = rvim.palette
  require('sniprun').setup({
    snipruncolors = {
      SniprunVirtualTextOk = {
        bg = P.darker_blue,
        fg = P.black,
        ctermbg = 'Cyan',
        cterfg = 'Black',
      },
      SniprunFloatingWinOk = { fg = P.darker_blue, ctermfg = 'Cyan' },
      SniprunVirtualTextErr = {
        bg = P.error_red,
        fg = P.black,
        ctermbg = 'DarkRed',
        cterfg = 'Cyan',
      },
      SniprunFloatingWinErr = { fg = P.error_red, ctermfg = 'DarkRed' },
    },
  })

  rvim.nnoremap('<leader>sr', ':SnipRun<cr>', 'sniprun: run')
  rvim.vnoremap('<leader>sr', ':SnipRun<cr>', 'sniprun: run')
  rvim.nnoremap('<leader>sc', ':SnipClose<cr>', 'sniprun: close')
  rvim.nnoremap('<leader>sx', ':SnipReset<cr>', 'sniprun: reset')
end
