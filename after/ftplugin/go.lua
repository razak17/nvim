vim.opt_local.expandtab = false
vim.opt_local.textwidth = 0 -- Go doesn't specify a max line length so don't force one
vim.opt_local.softtabstop = 0
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.smarttab = true
vim.cmd([[setlocal iskeyword+=-]])

if not rvim then return end

local ok, whichkey = rvim.safe_require('which-key')
if not ok then return end

whichkey.register({
  ['<leader>G'] = {
    name = '+Go',
    b = { '<Cmd>GoBuild<CR>', 'build' },
    f = {
      name = '+fix/fill',
      s = { '<Cmd>GoFillStruct<CR>', 'fill struct' },
      p = { '<Cmd>GoFixPlurals<CR>', 'fix plurals' },
    },
    ie = { '<Cmd>GoIfErr<CR>', 'if err' },
  },
})
