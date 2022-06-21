return function()
  local bufferline_ok, bufferline = rvim.safe_require("bufferline")
  if not bufferline_ok then
    return
  end

  local P = rvim.palette
  local groups = require("bufferline.groups")
  local util = require("user.utils.highlights")
  local normal_bg = util.get("Normal", "bg")
  local darker_bg = util.alter_color(normal_bg, -1)
  local bg = rvim.util.transparent_window == true and "none" or P.dark
  local fg_def = P.base88
  local fg_sel = P.base00

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
    buffer_selected = { guifg = fg_sel, guibg = bg },
    diagnostic = { guifg = P.pale_red, guibg = darker_bg },
    diagnostic_visible = { guifg = P.pale_red, guibg = darker_bg },
    diagnostic_selected = { guifg = P.pale_red, guibg = bg },
    error = { guifg = P.pale_red, guibg = darker_bg },
    error_visible = { guifg = P.pale_red, guibg = darker_bg },
    error_selected = { guifg = P.pale_red, guibg = bg },
    error_diagnostic = { guifg = P.pale_red, guibg = darker_bg },
    error_diagnostic_visible = { guifg = P.pale_red, guibg = darker_bg },
    error_diagnostic_selected = { guifg = P.pale_red, guibg = bg },
    info = { guifg = P.pale_blue, guibg = darker_bg },
    info_visible = { guifg = P.pale_blue, guibg = darker_bg },
    info_selected = { guifg = P.pale_blue, guibg = bg },
    info_diagnostic = { guifg = P.pale_blue, guibg = darker_bg },
    info_diagnostic_visible = { guifg = P.pale_blue, guibg = darker_bg },
    info_diagnostic_selected = { guifg = P.pale_blue, guibg = bg },
    warning = { guifg = P.dark_orange, guibg = darker_bg },
    warning_visible = { guifg = P.dark_orange, guibg = darker_bg },
    warning_selected = { guifg = P.dark_orange, guibg = bg },
    warning_diagnostic = { guifg = P.dark_orange, guibg = darker_bg },
    warning_diagnostic_visible = { guifg = P.dark_orange, guibg = darker_bg },
    warning_diagnostic_selected = { guifg = P.dark_orange, guibg = bg },
    modified = { guibg = darker_bg },
    modified_visible = { guibg = darker_bg },
    modified_selected = { guibg = bg },
    separator = { guifg = P.dark_orange, guibg = darker_bg },
    separator_visible = { guifg = P.dark_orange, guibg = darker_bg },
    separator_selected = { guifg = P.dark_orange, guibg = darker_bg },
    pick = { guifg = P.pink, guibg = darker_bg },
    pick_visible = { guifg = P.pink, guibg = darker_bg },
    pick_selected = { guifg = P.pale_blue, guibg = bg },
    indicator_selected = { guifg = darker_bg, guibg = bg },
  }

  rvim.bufferline = {
    setup = {
      options = {
        debug = {
          logging = true,
        },
        navigation = { mode = "uncentered" },
        mode = "buffers", -- tabs
        sort_by = "insert_after_current",
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
            filetype = "neo-tree",
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
          {
            filetype = "packer",
            text = "Packer",
            highlight = "PanelHeading",
            padding = 1,
          },
        },
      },
      groups = {
        options = {
          toggle_hidden_on_enter = true,
        },
        items = {
          groups.builtin.pinned:with({ icon = "" }),
          groups.builtin.ungrouped,
          {
            name = "Terraform",
            matcher = function(buf)
              return buf.name:match("%.tf") ~= nil
            end,
          },
          {
            name = "SQL",
            matcher = function(buf)
              return buf.filename:match("%.sql$")
            end,
          },
          {
            name = "tests",
            icon = "",
            matcher = function(buf)
              local name = buf.filename
              if name:match("%.sql$") == nil then
                return false
              end
              return name:match("_spec") or name:match("_test")
            end,
          },
          {
            name = "docs",
            icon = "",
            matcher = function(buf)
              for _, ext in ipairs({ "md", "txt", "org", "norg", "wiki" }) do
                if ext == vim.fn.fnamemodify(buf.path, ":e") then
                  return true
                end
              end
            end,
          },
        },
      },
      highlights = highlights,
    },
  }

  bufferline.setup(rvim.bufferline.setup)

  rvim.nnoremap("<S-l>", ":BufferLineCycleNext<CR>")
  rvim.nnoremap("<S-h>", ":BufferLineCyclePrev<CR>")
  rvim.nnoremap("gb", ":BufferLinePick<CR>", "bufferline: goto buffer")

  require("which-key").register({
    ["<leader>bh"] = { ":BufferLineMovePrev<CR>", "bufferline: move left" },
    ["<leader>bl"] = { ":BufferLineMoveNext<CR>", "bufferline: move right" },
    ["<leader>bH"] = { ":BufferLineCloseLeft<CR>", "bufferline: close left" },
    ["<leader>bL"] = { ":BufferLineCloseRight<CR>", "bufferline: close right" },
    ["<leader>bp"] = { ":BufferLineTogglePin<CR>", "bufferline: toggle pin" },
  })
end
