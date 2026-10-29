ar.pack.add({
  {
    src = 'https://github.com/SmiteshP/nvim-navbuddy',
    cond = function()
      local condition = not ar.plugins.minimal and ar.lsp.enable
      return ar.get_plugin_cond('nvim-navbuddy', condition)
    end,
    cmd = { 'Navbuddy' },
    lazy = false,
    keys = {
      { '<leader>nv', '<Cmd>Navbuddy<CR>', desc = 'navbuddy: toggle' },
    },
    dependencies = {
      { src = 'https://github.com/SmiteshP/nvim-navic' },
      { src = 'https://github.com/MunifTanjim/nui.nvim' },
    },
    setup = function()
      require('nvim-navbuddy').setup({ lsp = { auto_attach = true } })
    end,
  },
  {
    src = 'https://github.com/razak17/hierarchy.nvim',
    lazy = false,
    init = function()
      ar.add_to_select('lsp', {
        ['Function References'] = 'FuncReferences',
      })
    end,
    cond = function()
      return ar.get_plugin_cond('hierarchy.nvim', ar.lsp.enable)
    end,
    setup = function() require('hierarchy').setup() end,
  },
  {
    src = 'https://github.com/bassamsdata/namu.nvim',
    desc = 'Flexible and sleek fuzzy picker, LSP symbol navigator, and more. inspired by Zed.',
    cond = function() return ar.get_plugin_cond('namu.nvim', ar.lsp.enable) end,
    cmd = { 'Namu' },
    keys = function()
      local mappings = {
        {
          '<leader>ld',
          '<Cmd>Namu diagnostics<CR>',
          desc = 'namu: diagnostics',
        },
      }
      if
        ar.config.lsp.symbols.enable
        and ar.config.lsp.symbols.variant == 'namu'
      then
        ar.list_insert(mappings, {
          {
            '<leader>lsd',
            '<Cmd>Namu symbols<CR>',
            desc = 'namu: document symbols',
          },
          {
            '<leader>lsw',
            '<Cmd>Namu workspace<CR>',
            desc = 'namu: workspace symbols',
          },
        })
      end
      return mappings
    end,
    setup = function()
      require('namu').setup({
        namu_symbols = {
          enable = true,
          options = {}, -- here you can configure namu
        },
        ui_select = { enable = false }, -- vim.ui.select() wrapper
      })
    end,
  },
})
