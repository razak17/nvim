local options = {
  view = "default",
  close_icon = '',
  buffer_close_icon = '',
  modified_icon = "",
  tab_size = 0,
  enforce_regular_tabs = false,
  diagnostics = "nvim_lsp",
  separator_style = {'', ''},
  diagnostics_indicator = function()
    return ''
  end,
  numbers = "none",
  number_style = "superscript",
  show_buffer_close_icons = false,
  persist_buffer_sort = true,
  always_show_bufferline = true
}

local bg_def = 'none'
local bg_dark = '#202328'
local fg_def = '#4e4e4e'
local fg_sel = '#bebebe'
local fg_error = '#ff000e'
local fg_warn = '#ffcc77'

local highlights = {
  fill = {guifg = fg_def, guibg = bg_dark},
  background = {guifg = fg_def, guibg = bg_dark},
  buffer_visible = {guifg = fg_def, guibg = bg_dark},
  buffer_selected = {guifg = fg_sel, guibg = bg_dark},
  warning = {guifg = fg_warn},
  warning_visible = {guifg = fg_warn},
  warning_selected = {guifg = fg_warn},
  error = {guifg = fg_error, guibg = bg_def},
  error_visible = {guifg = fg_error},
  error_selected = {guifg = fg_error},
  modified = {guibg = bg_def},
  modified_visible = {guibg = bg_dark},
  modified_selected = {guibg = bg_dark},
  indicator_selected = {guifg = bg_dark, guibg = bg_dark},
  tab = {guifg = fg_def, guibg = bg_dark},
  tab_selected = {guifg = fg_sel, guibg = bg_dark},
  tab_close = {guifg = fg_def, guibg = bg_dark}
}

require'bufferline'.setup {options = options, highlights = highlights}
