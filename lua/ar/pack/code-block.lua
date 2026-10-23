ar.pack.add({
  ------------------------------------------------------------------------------
  -- Edit Code Blocks
  ------------------------------------------------------------------------------
  {
    src = 'https://github.com/dawsers/edit-code-block.nvim',
    cond = function()
      return ar.get_plugin_cond('edit-code-block.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    setup = function() require('ecb').setup({ wincmd = 'split' }) end,
  },
  {
    src = 'https://github.com/haolian9/nag.nvim',
    cond = function()
      return ar.get_plugin_cond('nag.nvim', not ar.plugins.minimal)
    end,
    dependencies = {
      { src = 'https://github.com/haolian9/infra.nvim' },
    },
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
})
