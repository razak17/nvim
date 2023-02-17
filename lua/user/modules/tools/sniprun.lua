return {
  'michaelb/sniprun',
  cmd = { 'SnipRun', 'SnipInfo', 'SnipReset', 'SnipClose', 'SnipLive' },
  build = 'bash ./install.sh',
  keys = {
    { '<localleader>sr', '<cmd>SnipRun<CR>', desc = 'sniprun: run' },
    { '<localleader>sr', '<cmd>SnipRun<CR>', desc = 'sniprun: run', mode = 'v' },
    { '<localleader>so', '<cmd>SnipRunOperator<CR>', desc = 'sniprun: run operator' },
    { '<localleader>sc', '<cmd>SnipClose<CR>', desc = 'sniprun: close' },
    { '<localleader>sl', '<cmd>SnipLive<CR>', desc = 'sniprun: live mode' },
    { '<localleader>sx', '<cmd>SnipReset<CR>', desc = 'sniprun: reset' },
  },
  config = function()
    local P = require('zephyr.palette')
    require('sniprun').setup({
      live_mode_toggle = 'enable',
      snipruncolors = {
        SniprunVirtualTextOk = {
          bg = P.bg_highlight,
          fg = P.dark_cyan,
          ctermbg = 'LightBlue',
          cterfg = 'Black',
        },
        SniprunFloatingWinOk = { fg = P.bg_highlight, ctermfg = 'LightBlue' },
        SniprunVirtualTextErr = {
          bg = P.error_red,
          fg = P.black,
          ctermbg = 'DarkRed',
          cterfg = 'Black',
        },
        SniprunFloatingWinErr = { fg = P.error_red, ctermfg = 'DarkRed' },
      },
    })
  end,
}
