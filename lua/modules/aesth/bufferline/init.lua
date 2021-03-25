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
local fg_def = '#4e4e4e'
local fg_sel = '#c678dd'

local highlights = {
    fill = {guifg = fg_def, guibg = bg_def},
    background = {guifg = fg_def, guibg = bg_def},
    buffer_visible = {guifg = fg_def, guibg = bg_def},
    buffer_selected = {guifg = '#bebebe', guibg = bg_def},
    modified = {guibg = bg_def},
    modified_visible = {guibg = bg_def},
    modified_selected = {guibg = bg_def},
    indicator_selected = {guifg = fg_sel, guibg = bg_def},
    tab = {guifg = fg_def, guibg = bg_def},
    tab_selected = {guifg = fg_def, guibg = bg_def},
    tab_close = {guifg = fg_def, guibg = bg_def}
}

require'bufferline'.setup {options = options, highlights = highlights}
