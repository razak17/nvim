local minimal = ar.plugins.minimal
local get_cond = ar.get_plugin_cond

return {
  ------------------------------------------------------------------------------
  -- Edit Code Blocks
  ------------------------------------------------------------------------------
  {
    'dawsers/edit-code-block.nvim',
    cond = function() return get_cond('edit-code-block.nvim', not minimal) end,
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    opts = { wincmd = 'split' },
  },
  {
    'haolian9/nag.nvim',
    cond = function() return get_cond('nag.nvim', not minimal) end,
    dependencies = { 'haolian9/infra.nvim' },
    init = function()
      vim.g.whichkey_add_spec({
        '<localleader>n',
        group = 'Nag',
        mode = { 'x' },
      })
    end,
    -- stylua: ignore
    keys = {
      { mode = 'x', '<localleader>nv', ":lua require'nag'.split('right')<CR>", desc = 'nag: split right', },
      { mode = 'x', '<localleader>ns', ":lua require'nag'.split('below')<CR>", desc = 'nag: split below', },
      { mode = 'x', '<localleader>nt', ":lua require'nag'.tab()<CR>", desc = 'nag: split tab', },
    },
  },
}
