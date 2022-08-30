vim.bo.expandtab = false
vim.bo.textwidth = 0 -- Go doesn't specify a max line length so don't force one
vim.bo.softtabstop = 0
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.smarttab = true
vim.opt_local.iskeyword:append('-')

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
