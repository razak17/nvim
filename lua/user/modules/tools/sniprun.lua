return function()
  local P = rvim.palette
  require("sniprun").setup {
    snipruncolors = {
      SniprunVirtualTextOk = { bg = P.darker_blue, fg = P.black, ctermbg = 'Cyan', cterfg = 'Black' },
      SniprunFloatingWinOk = { fg = P.darker_blue, ctermfg = 'Cyan' },
      SniprunVirtualTextErr = {
        bg = P.error_red,
        fg = P.black,
        ctermbg = 'DarkRed',
        cterfg = 'Cyan'      },
      SniprunFloatingWinErr = { fg = P.error_red, ctermfg = "DarkRed" },
    },
  }

  rvim.nnoremap("<leader>sr", ":SnipRun<cr>", { label = "sniprun: run" })
  rvim.vnoremap("<leader>sr", ":SnipRun<cr>", { label = "sniprun: run" })
  rvim.nnoremap("<leader>sc", ":SnipClose<cr>", { label = "sniprun: close" })
  rvim.nnoremap("<leader>sx", ":SnipReset<cr>", { label = "sniprun: reset" })
end
