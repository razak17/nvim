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
  local util = require "zephyr.util"
  local normal_bg = util.get_hl("Normal", "bg")
  local darker_bg = util.alter_color(normal_bg, -1)
  local bg = rvim.transparent_window == true and "none" or P.statusline_section_bg
  local fg_def = P.bufferline_fg_def
  local fg_sel = P.bufferline_fg_sel

  local highlights = {
    fill = { guifg = fg_def, guibg = darker_bg },
    background = { guifg = fg_def, guibg = darker_bg },
    tab = { guifg = fg_def, guibg = darker_bg },
    tab_selected = { guifg = fg_sel, guibg = bg },
    tab_close = { guifg = fg_def, guibg = darker_bg },
    duplicate = { guifg = fg_def, guibg = darker_bg },
    duplicate_visible = { guifg = fg_def, guibg = darker_bg },
    duplicate_selected = { guifg = P.base7, guibg = bg, gui = "italic" },
    buffer_visible = { guifg = fg_def, guibg = darker_bg },
    buffer_selected = { guifg = fg_sel, guibg = bg, gui = "NONE" },
    diagnostic = { guifg = P.pale_red, guibg = darker_bg },
    diagnostic_visible = { guifg = P.pale_red, guibg = darker_bg },
    diagnostic_selected = { guifg = P.pale_red, guibg = bg, gui = "NONE" },
    error = { guifg = P.pale_red, guibg = darker_bg },
    error_visible = { guifg = P.pale_red, guibg = darker_bg },
    error_selected = { guifg = P.pale_red, guibg = bg, gui = "NONE" },
    error_diagnostic = { guifg = P.pale_red, guibg = darker_bg },
    error_diagnostic_visible = { guifg = P.pale_red, guibg = darker_bg },
    error_diagnostic_selected = { guifg = P.pale_red, guibg = bg, gui = "NONE" },
    info = { guifg = P.pale_blue, guibg = darker_bg },
    info_visible = { guifg = P.pale_blue, guibg = darker_bg },
    info_selected = { guifg = P.pale_blue, guibg = bg, gui = "NONE" },
    info_diagnostic = { guifg = P.pale_blue, guibg = darker_bg },
    info_diagnostic_visible = { guifg = P.pale_blue, guibg = darker_bg },
    info_diagnostic_selected = { guifg = P.pale_blue, guibg = bg, gui = "NONE" },
    warning = { guifg = P.dark_orange, guibg = darker_bg },
    warning_visible = { guifg = P.dark_orange, guibg = darker_bg },
    warning_selected = { guifg = P.dark_orange, guibg = bg, gui = "NONE" },
    warning_diagnostic = { guifg = P.dark_orange, guibg = darker_bg },
    warning_diagnostic_visible = { guifg = P.dark_orange, guibg = darker_bg },
    warning_diagnostic_selected = { guifg = P.dark_orange, guibg = bg, gui = "NONE" },
    modified = { guibg = darker_bg },
    modified_visible = { guibg = darker_bg },
    modified_selected = { guibg = bg },
    separator = { guifg = P.dark_orange, guibg = darker_bg },
    separator_visible = { guifg = P.dark_orange, guibg = darker_bg },
    separator_selected = { guifg = P.dark_orange, guibg = darker_bg },
    pick = { guifg = P.magenta, guibg = darker_bg },
    pick_visible = { guifg = P.magenta, guibg = darker_bg },
    pick_selected = { guifg = P.pale_blue, guibg = bg },
    indicator_selected = { guifg = darker_bg, guibg = bg },
  }

  rvim.bufferline = {
    setup = {
      options = {
        mode = "buffers", -- tabs
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
            padding = 1,
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

  rvim.nnoremap("<S-l>", ":BufferLineCycleNext<CR>")
  rvim.nnoremap("<S-h>", ":BufferLineCyclePrev<CR>")
  rvim.nnoremap("gb", ":BufferLinePick<CR>")

  require("which-key").register {
    ["<leader>bh"] = { ":BufferLineMovePrev<CR>", "move left" },
    ["<leader>bl"] = { ":BufferLineMoveNext<CR>", "move right" },
    ["<leader>bH"] = { ":BufferLineCloseLeft<CR>", "close left" },
    ["<leader>bL"] = { ":BufferLineCloseRight<CR>", "close right" },
  }
end
