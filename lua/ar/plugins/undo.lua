local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Undo Tree'] = 'UndotreeToggle' })
    end,
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },
  {
    'kevinhwang91/nvim-fundo',
    cond = not minimal,
    event = { 'BufRead', 'BufNewFile' },
    build = function() require('fundo').install() end,
  },
  {
    'tzachar/highlight-undo.nvim',
    cond = not minimal and niceties,
    event = 'BufRead',
    opts = {
      undo = { hlgroup = 'Search' },
      redo = { hlgroup = 'Search' },
    },
  },
}
