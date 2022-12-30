local M = {
  'michaelb/sniprun',
  cmd = { 'SnipRun', 'SnipInfo', 'SnipReset', 'SnipClose', 'SnipLive' },
  build = 'bash ./install.sh',
}

function M.init()
  rvim.nnoremap('<localleader>sr', '<cmd>SnipRun<CR>', 'sniprun: run')
  rvim.nnoremap('<localleader>so', '<cmd>SnipRunOperator<CR>', 'sniprun: run operator')
  rvim.vnoremap('<localleader>sr', ':SnipRun<CR>', 'sniprun: run')
  rvim.nnoremap('<localleader>sc', '<cmd>SnipClose<CR>', 'sniprun: close')
  rvim.nnoremap('<localleader>sl', '<cmd>SnipLive<CR>', 'sniprun: live mode')
  rvim.nnoremap('<localleader>sx', '<cmd>SnipReset<CR>', 'sniprun: reset')
end

function M.config()
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
end

return M
