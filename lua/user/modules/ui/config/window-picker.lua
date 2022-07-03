return function()
  require('window-picker').setup({
    autoselect_one = true,
    include_current = false,
    filter_rules = {
      bo = {
        filetype = { 'neo-tree-popup', 'quickfix', 'incline' },
        buftype = { 'terminal', 'quickfix', 'nofile' },
      },
    },
    other_win_hl_color = require('user.utils.highlights').get('Visual', 'bg'),
  })
end
