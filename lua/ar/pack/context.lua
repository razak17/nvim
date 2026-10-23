ar.pack.add({
  {
    src = 'https://github.com/ragnarok22/whereami.nvim',
    cmd = { 'Whereami' },
    cond = function() return ar.get_plugin_cond('whereami.nvim') end,
  },
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter-context',
    cond = function()
      return ar.get_plugin_cond('nvim-treesitter-context', ar.plugins.coding)
    end,
    keys = {
      {
        '[K',
        function() require('treesitter-context').go_to_context(vim.v.count1) end,
        desc = 'goto treesitter context',
      },
    },
    event = { 'BufRead', 'BufNewFile' },
    cmd = { 'TSContext' },
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Toggle TS Context'] = 'TSContext toggle' }
      )
    end,
    setup = function()
      ar.highlight.plugin('treesitter-context', {
        { TreesitterContextSeparator = { link = 'VertSplit' } },
        { TreesitterContext = { inherit = 'NormalFloat' } },
        { TreesitterContextLineNumber = { inherit = 'LineNr' } },
      })
      require('treesitter-context').setup({
        multiline_threshold = 4,
        separator = '─', -- alternatives: ▁ ─ ▄
        mode = 'cursor',
      })
    end,
  },
  {
    src = 'https://github.com/andersevenrud/nvim_context_vt',
    cond = function()
      return ar.get_plugin_cond('nvim_context_vt', ar.plugins.coding)
    end,
    cmd = { 'NvimContextVtToggle' },
    init = function()
      ar.add_to_select(
        'command_palette',
        { ['Toggle Context Visualizer'] = 'NvimContextVtToggle' }
      )
    end,

    setup = function()
      require('nvim_context_vt').setup({ highlight = 'Comment' })
      vim.cmd([[NvimContextVtToggle]])
    end,
  },
})
