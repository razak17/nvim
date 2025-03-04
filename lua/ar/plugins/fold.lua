return {
  {
    'kevinhwang91/nvim-ufo',
    cond = not ar.plugins.minimal,
    -- stylua: ignore
    keys = {
		  { '<leader>uf', vim.cmd.UfoInspect, desc = 'ufo: fold info' },
      {
        'zr',
        function() require('ufo').openFoldsExceptKinds { 'comment', 'imports' } end,
        desc = 'ufo: open regular folds',
      },
      { 'zR', '<Cmd>lua require("ufo").openAllFolds()<CR>', desc = 'ufo: open all folds' },
      { 'zM', '<Cmd>lua require("ufo").closeAllFolds()<CR>', desc = 'ufo: close all folds' },
      { 'zK', '<Cmd>lua require("ufo").peekFoldedLinesUnderCursor()<CR>', desc = 'ufo: preview fold' },
      { 'z1', '<Cmd>lua require("ufo").closeFoldsWith(1)<CR>', desc = 'ufo: close L1 folds' },
      { 'z2', '<Cmd>lua require("ufo").closeFoldsWith(2)<CR>', desc = 'ufo: close L2 folds' },
      { 'z3', '<Cmd>lua require("ufo").closeFoldsWith(3)<CR>', desc = 'ufo: close L3 folds' },
      { 'z4', '<Cmd>lua require("ufo").closeFoldsWith(4)<CR>', desc = 'ufo: close L4 folds' },
    },
    opts = function()
      local ft_map = { rust = 'lsp' }
      require('ufo').setup({
        open_fold_hl_timeout = 0,
        preview = {
          win_config = {
            border = ar.ui.current.border,
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
      ar.highlight.plugin('ufo', {
        theme = {
          ['onedark'] = {
            { UfoCursorFoldedLine = { link = 'Folded' } },
          },
        },
      })
    end,
  },
  {
    'chrisgrieser/nvim-origami',
    cond = not ar.plugins.minimal,
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
      ar.highlight.plugin('fold_line', {
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
