local M = { 'ggandor/leap.nvim', event = 'VeryLazy' }

function M.init()
  rvim.nnoremap('s', function()
    require('leap').leap({
      target_windows = vim.tbl_filter(
        function(win) return rvim.empty(vim.fn.win_gettype(win)) end,
        vim.api.nvim_tabpage_list_wins(0)
      ),
    })
  end, 'leap: search')
end

function M.config()
  rvim.highlight.plugin('leap', {
    theme = {
      ['*'] = {
        { LeapBackdrop = { fg = '#707070' } },
      },
      horizon = {
        { LeapLabelPrimary = { bg = 'NONE', fg = '#ccff88', italic = true } },
        { LeapLabelSecondary = { bg = 'NONE', fg = '#99ccff' } },
        { LeapLabelSelected = { bg = 'NONE', fg = 'Magenta' } },
      },
    },
  })
  require('leap').setup({
    equivalence_classes = { ' \t\r\n', '([{', ')]}', '`"\'' },
  })
end

return M
