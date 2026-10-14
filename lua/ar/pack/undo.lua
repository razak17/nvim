local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

ar.pack.add({
  {
    src = 'https://github.com/mbbill/undotree',
    cond = function() return ar.get_plugin_cond('undotree') end,
    cmd = { 'UndotreeToggle' },
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    init = function()
      ar.add_to_select('toggle', { ['Toggle Undo Tree'] = 'UndotreeToggle' })
    end,
    setup = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },
  {
    src = 'https://github.com/XXiaoA/atone.nvim',
    cond = function() return ar.get_plugin_cond('atone.nvim', not minimal) end,
    cmd = { 'Atone' },
    setup = function() require('atone').setup() end,
  },
  {
    src = 'https://github.com/kevinhwang91/nvim-fundo',
    cond = function() return ar.get_plugin_cond('nvim-fundo', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    build = function() require('fundo').install() end,
  },
  {
    src = 'https://github.com/tzachar/highlight-undo.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('highlight-undo.nvim', condition)
    end,
    event = 'BufRead',
    setup = function()
      require('highlight-undo').setup({
        undo = { hlgroup = 'Search' },
        redo = { hlgroup = 'Search' },
      })
    end,
  },
})
