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

local bg_dark = '#282a36'
local bg_sel = '#1c1f24'
local fg_def = '#7e7e7e'
local fg_sel = '#dedede'
local fg_error = '#ff000e'
local fg_warn = '#ecbe7b'
local fg_info = '#51afef'
local pick_fg = '#c678dd'

local highlights = {
  fill = {guifg = fg_def, guibg = bg_dark},
  background = {guifg = fg_def, guibg = bg_dark},
  tab = {guifg = fg_def, guibg = bg_dark},
  tab_selected = {guifg = fg_sel, guibg = bg_sel},
  tab_close = {guifg = fg_def, guibg = bg_dark},
  duplicate = {guifg = fg_def, guibg = bg_dark},
  duplicate_visible = {guifg = fg_def, guibg = bg_dark},
  duplicate_selected = {guifg = fg_def, guibg = bg_sel, gui = "italic"},
  buffer_visible = {guifg = fg_def, guibg = bg_dark},
  buffer_selected = {guifg = fg_sel, guibg = bg_sel, gui = ""},
  error = {guifg = fg_error, guibg = bg_dark},
  error_visible = {guifg = fg_error, guibg = bg_dark},
  error_selected = {guifg = fg_error, guibg = bg_sel, gui = ""},
  info = {guifg = fg_info, guibg = bg_dark},
  info_visible = {guifg = fg_info, guibg = bg_dark},
  info_selected = {guifg = fg_info, guibg = bg_sel, gui = ""},
  warning = {guifg = fg_warn, guibg = bg_dark},
  warning_visible = {guifg = fg_warn, guibg = bg_dark},
  warning_selected = {guifg = fg_warn, guibg = bg_sel, gui = ""},
  modified = {guibg = bg_dark},
  modified_visible = {guibg = bg_dark},
  modified_selected = {guibg = bg_sel},
  separator = {guifg = fg_warn, guibg = bg_dark},
  separator_visible = {guifg = fg_warn, guibg = bg_dark},
  separator_selected = {guifg = fg_warn, guibg = bg_sel},
  pick = {guifg = pick_fg, guibg = bg_dark},
  pick_visible = {guifg = pick_fg, guibg = bg_dark},
  pick_selected = {guifg = fg_info, guibg = bg_sel},
  indicator_selected = {guifg = bg_dark, guibg = bg_sel}
}

require'bufferline'.setup {options = options, highlights = highlights}

