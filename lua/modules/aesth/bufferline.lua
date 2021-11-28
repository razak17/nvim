return function()
  local bufferline_ok, bufferline = rvim.safe_require "bufferline"
  if not bufferline_ok then
    return
  end

  local function is_ft(b, ft)
    return vim.bo[b].filetype == ft
  end

  local function custom_filter(buf, buf_nums)
    local logs = vim.tbl_filter(function(b)
      return is_ft(b, "log")
    end, buf_nums)
    if vim.tbl_isempty(logs) then
      return true
    end
    local tab_num = vim.fn.tabpagenr()
    local last_tab = vim.fn.tabpagenr "$"
    local is_log = is_ft(buf, "log")
    if last_tab == 1 then
      return true
    end
    -- only show log buffers in secondary tabs
    return (tab_num == last_tab and is_log) or (tab_num ~= last_tab and not is_log)
  end

  local P = rvim.palette
  local bg = rvim.common.transparent_window == true and "none" or P.bg
  local bg_sel = P.bufferline_bg_sel
  local fg_def = P.bufferline_fg_def
  local fg_sel = P.bufferline_fg_sel

  local highlights = {
    fill = { guifg = fg_def, guibg = bg },
    background = { guifg = fg_def, guibg = bg },
    tab = { guifg = fg_def, guibg = bg },
    tab_selected = { guifg = fg_sel, guibg = bg },
    tab_close = { guifg = fg_def, guibg = bg },
    duplicate = { guifg = fg_def, guibg = bg },
    duplicate_visible = { guifg = fg_def, guibg = bg },
    duplicate_selected = { guifg = P.base7, guibg = bg_sel, gui = "italic" },
    buffer_visible = { guifg = fg_def, guibg = bg },
    buffer_selected = { guifg = fg_sel, guibg = bg_sel, gui = "NONE" },
    diagnostic = { guifg = P.pale_red, guibg = bg },
    diagnostic_visible = { guifg = P.pale_red, guibg = bg },
    diagnostic_selected = { guifg = P.pale_red, guibg = bg_sel, gui = "NONE" },
    error = { guifg = P.pale_red, guibg = bg },
    error_visible = { guifg = P.pale_red, guibg = bg },
    error_selected = { guifg = P.pale_red, guibg = bg_sel, gui = "NONE" },
    error_diagnostic = { guifg = P.pale_red, guibg = bg },
    error_diagnostic_visible = { guifg = P.pale_red, guibg = bg },
    error_diagnostic_selected = { guifg = P.pale_red, guibg = bg_sel, gui = "NONE" },
    info = { guifg = P.bright_blue, guibg = bg },
    info_visible = { guifg = P.bright_blue, guibg = bg },
    info_selected = { guifg = P.bright_blue, guibg = bg_sel, gui = "NONE" },
    info_diagnostic = { guifg = P.bright_blue, guibg = bg },
    info_diagnostic_visible = { guifg = P.bright_blue, guibg = bg },
    info_diagnostic_selected = { guifg = P.bright_blue, guibg = bg_sel, gui = "NONE" },
    warning = { guifg = P.dark_orange, guibg = bg },
    warning_visible = { guifg = P.dark_orange, guibg = bg },
    warning_selected = { guifg = P.dark_orange, guibg = bg_sel, gui = "NONE" },
    warning_diagnostic = { guifg = P.dark_orange, guibg = bg },
    warning_diagnostic_visible = { guifg = P.dark_orange, guibg = bg },
    warning_diagnostic_selected = { guifg = P.dark_orange, guibg = bg_sel, gui = "NONE" },
    modified = { guibg = bg },
    modified_visible = { guibg = bg },
    modified_selected = { guibg = bg_sel },
    separator = { guifg = P.dark_orange, guibg = bg },
    separator_visible = { guifg = P.dark_orange, guibg = bg },
    separator_selected = { guifg = P.dark_orange, guibg = bg },
    pick = { guifg = P.magenta, guibg = bg },
    pick_visible = { guifg = P.magenta, guibg = bg },
    pick_selected = { guifg = P.bright_blue, guibg = bg_sel },
    indicator_selected = { guifg = bg, guibg = bg },
  }

  rvim.bufferline = {
    setup = {
      options = {
        view = "default",
        close_icon = "",
        buffer_close_icon = "",
        right_mouse_command = "vert sbuffer %d",
        show_buffer_close_icons = false,
        tab_size = 0,
        enforce_regular_tabs = false,
        diagnostics = "nvim_lsp",
        separator_style = { "", "" },
        diagnostics_indicator = function()
          return ""
        end,
        custom_filter = custom_filter,
        numbers = "none",
        offsets = {
          {
            filetype = "undotree",
            text = "Undotree",
            highlight = "PanelHeading",
            padding = 1,
          },
          {
            filetype = "NvimTree",
            text = "Explorer",
            highlight = "PanelBackground",
            padding = 0,
          },
          {
            filetype = "DiffviewFiles",
            text = "Diff View",
            highlight = "PanelHeading",
            padding = 1,
          },
          {
            filetype = "packer",
            text = "Packer",
            highlight = "PanelHeading",
            padding = 1,
          },
        },
      },
      highlights = highlights,
    },
  }

  bufferline.setup(rvim.bufferline.setup)
end
