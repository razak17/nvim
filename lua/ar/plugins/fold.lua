return {
  {
    'kevinhwang91/nvim-ufo',
    cond = not rvim.plugins.minimal,
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
        close_fold_kinds_for_ft = {
          default = { 'imports', 'comment' },
          json = { 'array' },
          c = { 'comment', 'region' },
        },
        provider_selector = function(_, ft)
          -- lsp better?
          return ft_map[ft] or { 'treesitter', 'indent' }
        end,
      })
    end,
    config = function()
      rvim.highlight.plugin('ufo', {
        theme = {
          -- stylua: ignore
          ['onedark'] = {
            { Folded = { bold = false, italic = false, bg = { from = 'CursorLine', alter = -0.15 } },
            },
          },
        },
      })
    end,
    dependencies = { 'kevinhwang91/promise-async' },
  },
  {
    'chrisgrieser/nvim-origami',
    cond = not rvim.plugins.minimal,
    -- event = 'BufReadPost',
    keys = {
      { '<BS>', function() require('origami').h() end, desc = 'close fold' },
    },
    opts = { setupFoldKeymaps = false },
  },
  {
    'gh-liu/fold_line.nvim',
    cond = false,
    event = 'VeryLazy',
    config = function()
      rvim.highlight.plugin('fold_line', {
        theme = {
          ['onedark'] = { { FoldLine = { link = 'IndentBlanklineChar' } } },
        },
      })
    end,
    init = function()
      -- change the char of the line, see the `Appearance` section
      vim.g.fold_line_char_open_start = '╭'
      vim.g.fold_line_char_open_end = '╰'
    end,
  },
}
