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
local bg_dark = '#282a36'
local fg_def = '#4e4e4e'
local fg_sel = '#dedede'
local bg_sel = '#000000'
local fg_error = '#ff000e'
local fg_warn = '#ffcc77'

local highlights = {
  fill = {guifg = fg_def, guibg = bg_dark},
  background = {guifg = fg_def, guibg = bg_dark},
  buffer_visible = {guifg = fg_def, guibg = bg_dark},
  buffer_selected = {guifg = fg_sel, guibg = bg_sel},
  warning = {guifg = fg_warn, guibg = bg_dark},
  warning_visible = {guifg = fg_warn, guibg = bg_dark},
  warning_selected = {guifg = fg_warn, guibg = bg_sel},
  error = {guifg = fg_error, guibg = bg_dark},
  error_visible = {guifg = fg_error, guibg = bg_dark},
  error_selected = {guifg = fg_error, guibg = bg_sel},
  modified = {guibg = bg_def},
  modified_visible = {guibg = bg_dark},
  modified_selected = {guibg = bg_sel},
  indicator_selected = {guifg = bg_dark, guibg = bg_sel},
  tab = {guifg = fg_def, guibg = bg_dark},
  tab_selected = {guifg = fg_sel, guibg = bg_sel},
  tab_close = {guifg = fg_def, guibg = bg_dark}
}

require'bufferline'.setup {options = options, highlights = highlights}
