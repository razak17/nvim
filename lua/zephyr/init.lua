local P = rvim.palette

local zephyr = {}

function zephyr.terminal_color()
  vim.g.terminal_color_0 = P.bg
  vim.g.terminal_color_1 = P.red
  vim.g.terminal_color_2 = P.green
  vim.g.terminal_color_3 = P.yellow
  vim.g.terminal_color_4 = P.blue
  vim.g.terminal_color_5 = P.violet
  vim.g.terminal_color_6 = P.cyan
  vim.g.terminal_color_7 = P.bg_visual
  vim.g.terminal_color_8 = P.brown
  vim.g.terminal_color_9 = P.red
  vim.g.terminal_color_10 = P.green
  vim.g.terminal_color_11 = P.yellow
  vim.g.terminal_color_12 = P.blue
  vim.g.terminal_color_13 = P.violet
  vim.g.terminal_color_14 = P.cyan
  vim.g.terminal_color_15 = P.fg
end

function zephyr.highlight(group, color)
  local style = color.style and 'gui=' .. color.style or 'gui=NONE'
  local fg = color.fg and 'guifg=' .. color.fg or 'guifg=NONE'
  local bg = color.bg and 'guibg=' .. color.bg or 'guibg=NONE'
  local sp = color.sp and 'guisp=' .. color.sp or ''
  vim.cmd('highlight ' .. group .. ' ' .. style .. ' ' .. fg .. ' ' .. bg .. ' ' .. sp)
end

local async_load_plugin

local set_hl = function(tbl)
  for group, conf in pairs(tbl) do
    vim.api.nvim_set_hl(0, group, conf)
  end
end

local plugin_syntax = require('zephyr.plugin')

async_load_plugin = vim.loop.new_async(vim.schedule_wrap(function()
  zephyr.terminal_color()
  set_hl(plugin_syntax)
  async_load_plugin:close()
end))

function zephyr.colorscheme()
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') then
    vim.cmd('syntax reset')
  end
  vim.o.background = 'dark'
  vim.o.termguicolors = true
  vim.g.colors_name = 'zephyr'
  local syntax = require('zephyr.syntax')
  set_hl(syntax)
  async_load_plugin:send()
end

zephyr.colorscheme()

return zephyr
