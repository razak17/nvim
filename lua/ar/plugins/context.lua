local coding = ar.plugins.coding

return {
  { 'ragnarok22/whereami.nvim', cmd = 'Whereami' },
  {
    'nvim-treesitter/nvim-treesitter-context',
    cond = function()
      return ar.get_plugin_cond('nvim-treesitter-context', coding)
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
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle TS Context'] = 'TSContext toggle' }
      )
    end,
    config = function()
      ar.highlight.plugin('treesitter-context', {
        theme = {
          ['onedark'] = {
            { TreesitterContextSeparator = { link = 'VertSplit' } },
            { TreesitterContext = { inherit = 'Normal' } },
            { TreesitterContextLineNumber = { inherit = 'LineNr' } },
          },
        },
      })
      require('treesitter-context').setup({
        multiline_threshold = 4,
        separator = '─', -- alternatives: ▁ ─ ▄
        mode = 'cursor',
      })
    end,
  },
  {
    'andersevenrud/nvim_context_vt',
    cond = function()
      local condition = coding and ar.ts_extra_enabled
      return ar.get_plugin_cond('nvim_context_vt', condition)
    end,
    cmd = 'NvimContextVtToggle',
    init = function()
      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Context Visualizer'] = 'NvimContextVtToggle' }
      )
    end,
    opts = { highlight = 'Comment' },
    config = function(_, opts)
      require('nvim_context_vt').setup(opts)
      vim.cmd([[NvimContextVtToggle]])
    end,
  },
  {
    'nabekou29/pair-lens.nvim',
    cond = function()
      local condition = coding and ar.ts_extra_enabled
      return ar.get_plugin_cond('pair-lens.nvim', condition)
    end,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = { 'PairLensToggle', 'PairLensEnable', 'PairLensDisable' },
    opts = {},
  },
}
