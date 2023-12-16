return {
  {
    'kevinhwang91/nvim-ufo',
    cond = rvim.treesitter.enable,
    event = 'VeryLazy',
    -- stylua: ignore
    keys = {
      { 'zR', '<Cmd>lua require("ufo").openAllFolds()<CR>', 'ufo: open all folds' },
      { 'zM', '<Cmd>lua require("ufo").closeAllFolds()<CR>', 'ufo: close all folds' },
      { 'zK', '<Cmd>lua require("ufo").peekFoldedLinesUnderCursor()<CR>', 'ufo: preview fold' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = rvim.ui.current.border,
            winhighlight = 'NormalFloat:FloatBorder,FloatBorder:FloatBorder',
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
    config = function()
      rvim.highlight.plugin('ufo', {
        theme = {
          ['onedark'] = {
            {
              Folded = {
                bold = false,
                italic = false,
                bg = { from = 'CursorLine', alter = -0.15 },
              },
            },
          },
        },
      })
    end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'chrisgrieser/nvim-origami',
    cond = rvim.treesitter.enable,
    -- event = 'BufReadPost',
    keys = {
      { '<BS>', function() require('origami').h() end, desc = 'toggle fold' },
    },
    opts = { setupFoldKeymaps = false },
  },
}
