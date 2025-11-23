local minimal = ar.plugins.minimal

return {
  {
    'SmiteshP/nvim-navbuddy',
    cond = function()
      local condition = not minimal and ar.lsp.enable
      return ar.get_plugin_cond('nvim-navbuddy', condition)
    end,
    cmd = { 'Navbuddy' },
    lazy = false,
    keys = {
      { '<leader>nv', '<Cmd>Navbuddy<CR>', desc = 'navbuddy: toggle' },
    },
    dependencies = { 'SmiteshP/nvim-navic' },
    opts = { lsp = { auto_attach = true } },
  },
  {
    'razak17/hierarchy.nvim',
    init = function()
      ar.add_to_select_menu('lsp', {
        ['Function References'] = 'FuncReferences',
      })
    end,
    cond = function()
      return ar.get_plugin_cond('hierarchy.nvim', ar.lsp.enable)
    end,
    opts = {},
  },
  {
    desc = 'Flexible and sleek fuzzy picker, LSP symbol navigator, and more. inspired by Zed.',
    'bassamsdata/namu.nvim',
    cond = function() return ar.get_plugin_cond('namu.nvim', ar.lsp.enable) end,
    cmd = { 'Namu' },
    -- stylua: ignore
    keys = function()
      local mappings = { { '<leader>ld', '<Cmd>Namu diagnostics<CR>', desc = 'namu: diagnostics' }, }
      if ar_config.lsp.symbols.enable and ar_config.lsp.symbols.variant == 'namu' then
        ar.list_insert(mappings, {
          { '<leader>lsd', '<Cmd>Namu symbols<CR>', desc = 'namu: document symbols' },
          { '<leader>lsw', '<Cmd>Namu workspace<CR>', desc = 'namu: workspace symbols' },
        })
      end
      return mappings
    end,
    opts = {
      namu_symbols = {
        enable = true,
        options = {}, -- here you can configure namu
      },
      ui_select = { enable = false }, -- vim.ui.select() wrapper
    },
  },
}
