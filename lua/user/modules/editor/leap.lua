local api, fn = vim.api, vim.fn
local hl = rvim.highlight

local function leap_keys()
  require('leap').leap({
    target_windows = vim.tbl_filter(
      function(win) return rvim.empty(fn.win_gettype(win)) end,
      api.nvim_tabpage_list_wins(0)
    ),
  })
end

return {
  'ggandor/leap.nvim',
  event = 'VeryLazy',
  keys = { { 's', leap_keys, mode = 'n' } },
  opts = { equivalence_classes = { ' \t\r\n', '([{', ')]}', '`"\'' } },
  config = function(_, opts)
    hl.plugin('leap', {
      theme = {
        ['*'] = { { LeapBackdrop = { fg = '#707070' } } },
      },
    })
    require('leap').setup(opts)
  end,
}
