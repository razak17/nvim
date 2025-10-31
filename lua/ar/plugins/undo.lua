local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'mbbill/undotree',
    cond = function() return ar.get_plugin_cond('undotree') end,
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    init = function()
      ar.add_to_select_menu(
        'toggle',
        { ['Toggle Undo Tree'] = 'UndotreeToggle' }
      )
    end,
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },
  {
    'XXiaoA/atone.nvim',
    cond = function() return ar.get_plugin_cond('atone.nvim', not minimal) end,
    cmd = 'Atone',
    opts = {},
  },
  {
    'kevinhwang91/nvim-fundo',
    cond = function() return ar.get_plugin_cond('nvim-fundo', not minimal) end,
    event = { 'BufRead', 'BufNewFile' },
    build = function() require('fundo').install() end,
  },
  {
    'tzachar/highlight-undo.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('highlight-undo.nvim', condition)
    end,
    event = 'BufRead',
    opts = {
      undo = { hlgroup = 'Search' },
      redo = { hlgroup = 'Search' },
    },
  },
}
