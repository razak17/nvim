return function()
  vim.cmd [[packadd nvim-web-devicons]]

  local nnoremap = rvim.nnoremap

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

  local options = {
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
    -- numbers = function(opts)
    --   return string.format("%s|%s.)", opts.id, opts.raise(opts.ordinal))
    -- end,
    offsets = {
      {
        filetype = "NvimTree",
        text = "Explorer",
        highlight = "PanelHeading",
        padding = 1,
      },
      {
        filetype = "DiffviewFiles",
        text = "Diff View",
        highlight = "PanelHeading",
        padding = 1,
      },
      { filetype = "flutterToolsOutline" },
    },
  }

  -- local bg = '#282a36'
  local bg = rvim.common.transparent_window == true and "none" or "#282a36"
  local bg_sel = "#3f444a"
  local base7 = "#9ca0a4"
  local fg_def = "#7e7e7e"
  local fg_sel = "#dedede"
  local fg_error = "#ff000e"
  local fg_warn = "#ecbe7b"
  local fg_info = "#51afef"
  local pick_fg = "#c678dd"

  local highlights = {
    fill = { guifg = fg_def, guibg = bg },
    background = { guifg = fg_def, guibg = bg },
    tab = { guifg = fg_def, guibg = bg },
    tab_selected = { guifg = fg_sel, guibg = bg },
    tab_close = { guifg = fg_def, guibg = bg },
    duplicate = { guifg = fg_def, guibg = bg },
    duplicate_visible = { guifg = fg_def, guibg = bg },
    duplicate_selected = { guifg = base7, guibg = bg_sel, gui = "italic" },
    buffer_visible = { guifg = fg_def, guibg = bg },
    buffer_selected = { guifg = fg_sel, guibg = bg_sel, gui = "NONE" },
    diagnostic = { guifg = fg_error, guibg = bg },
    diagnostic_visible = { guifg = fg_error, guibg = bg },
    diagnostic_selected = { guifg = fg_error, guibg = bg_sel, gui = "NONE" },
    error = { guifg = fg_error, guibg = bg },
    error_visible = { guifg = fg_error, guibg = bg },
    error_selected = { guifg = fg_error, guibg = bg_sel, gui = "NONE" },
    error_diagnostic = { guifg = fg_error, guibg = bg },
    error_diagnostic_visible = { guifg = fg_error, guibg = bg },
    error_diagnostic_selected = { guifg = fg_error, guibg = bg_sel, gui = "NONE" },
    info = { guifg = fg_info, guibg = bg },
    info_visible = { guifg = fg_info, guibg = bg },
    info_selected = { guifg = fg_info, guibg = bg_sel, gui = "NONE" },
    info_diagnostic = { guifg = fg_info, guibg = bg },
    info_diagnostic_visible = { guifg = fg_info, guibg = bg },
    info_diagnostic_selected = { guifg = fg_info, guibg = bg_sel, gui = "NONE" },
    warning = { guifg = fg_warn, guibg = bg },
    warning_visible = { guifg = fg_warn, guibg = bg },
    warning_selected = { guifg = fg_warn, guibg = bg_sel, gui = "NONE" },
    warning_diagnostic = { guifg = fg_warn, guibg = bg },
    warning_diagnostic_visible = { guifg = fg_warn, guibg = bg },
    warning_diagnostic_selected = { guifg = fg_warn, guibg = bg_sel, gui = "NONE" },
    modified = { guibg = bg },
    modified_visible = { guibg = bg },
    modified_selected = { guibg = bg_sel },
    separator = { guifg = fg_warn, guibg = bg },
    separator_visible = { guifg = fg_warn, guibg = bg },
    separator_selected = { guifg = fg_warn, guibg = bg },
    pick = { guifg = pick_fg, guibg = bg },
    pick_visible = { guifg = pick_fg, guibg = bg },
    pick_selected = { guifg = fg_info, guibg = bg_sel },
    indicator_selected = { guifg = bg, guibg = bg },
  }

  require("bufferline").setup { options = options, highlights = highlights }

  -- Mappings

  -- Bufferline
  nnoremap("<tab>", ":BufferLineCycleNext<CR>")
  nnoremap("<s-tab>", ":BufferLineCyclePrev<CR>")
  nnoremap("<Leader>bn", ":BufferLineMoveNext<CR>")
  nnoremap("<Leader>bb", ":BufferLineMovePrev<CR>")
  nnoremap("gb", ":BufferLinePick<CR>")
end
