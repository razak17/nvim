local cmd = vim.cmd

local M = {}

function M.enable_transparent_mode()
  cmd('au ColorScheme * hi Normal ctermbg=none guibg=none')
  cmd('au ColorScheme * hi SignColumn ctermbg=none guibg=none')
  cmd('au ColorScheme * hi NormalNC ctermbg=none guibg=none')
  cmd('au ColorScheme * hi MsgArea ctermbg=none guibg=none')
  cmd('au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none')
  cmd('au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none')
  cmd('au ColorScheme * hi EndOfBuffer ctermbg=none guibg=none')
  cmd("let &fcs='eob: '")
end

return M
