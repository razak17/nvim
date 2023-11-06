local highlight = rvim.highlight

return {
  {
    'kevinhwang91/nvim-ufo',
    cond = rvim.treesitter.enable and false,
    event = 'VeryLazy',
    config = function()
      highlight.plugin('ufo', {
        {
          Folded = {
            bold = false,
            italic = false,
            bg = { from = 'CursorLine', alter = -0.15 },
          },
        },
      })
    end,
    keys = {
      {
        'zR',
        function() require('ufo').openAllFolds() end,
        'ufo: open all folds',
      },
      {
        'zM',
        function() require('ufo').closeAllFolds() end,
        'ufo: close all folds',
      },
      {
        'zP',
        function() require('ufo').peekFoldedLinesUnderCursor() end,
        'ufo: preview fold',
      },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = rvim.ui.current.border,
            winhighlight = 'Normal:VertSplit,FloatBorder:VertSplit',
          },
        },
        enable_get_fold_virt_text = true,
        close_fold_kinds = { 'imports', 'comment' },
        provider_selector = function(_, ft)
          -- lsp better?
          return ft_map[ft] or { 'treesitter', 'indent' }
        end,
      })
    end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'chrisgrieser/nvim-origami',
    cond = rvim.treesitter.enable,
    event = 'BufReadPost',
    keys = {
      { '<BS>', function() require('origami').h() end, desc = 'toggle fold' },
    },
    opts = { setupFoldKeymaps = false },
  },
}
