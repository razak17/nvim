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
    local hl = rvim.highlight
    require('sniprun').setup({
      live_mode_toggle = 'enable',
      snipruncolors = {
        SniprunVirtualTextOk = {
          bg = hl.get('FloatTitle', 'bg'),
          fg = hl.get('FloatTitle', 'fg'),
          ctermbg = 'LightBlue',
          cterfg = 'Black',
        },
        SniprunFloatingWinOk = { fg = hl.get('CursorLine', 'fg'), ctermfg = 'LightBlue' },
        SniprunVirtualTextErr = {
          bg = hl.get('DiagnosticVirtualTextError', 'bg'),
          fg = hl.get('DiagnosticVirtualTextError', 'fg'),
          ctermbg = 'DarkRed',
          cterfg = 'Black',
        },
        SniprunFloatingWinErr = {
          fg = hl.get('DiagnosticVirtualTextError', 'fg'),
          ctermfg = 'DarkRed',
        },
      },
    })
  end,
}
