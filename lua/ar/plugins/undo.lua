local minimal = ar.plugins.minimal

return {
  {
    'mbbill/undotree',
    cmd = 'UndotreeToggle',
    keys = {
      { '<leader>U', '<cmd>UndotreeToggle<CR>', desc = 'undotree: toggle' },
    },
    init = function()
      ar.add_to_menu('toggle', { ['Toggle Undo Tree'] = 'UndotreeToggle' })
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
}
