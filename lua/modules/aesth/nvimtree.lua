return function()
  rvim.nvimtree = {
    side = "right",
    width = 35,
    indent_markers = 1,
    special_files = { "README.md", "Makefile", "MAKEFILE" },
    ignore = { ".git", "node_modules", ".cache", ".DS_Store", "fugitive:" },
    respect_buf_cwd = 1,
    width_allow_resize = 1,
    disable_window_picker = 1,
    auto_ignore_ft = { "startify", "dashboard" },
    setup = {
      auto_open = false,
      auto_close = true,
    }
  }

  local status_ok, nvim_tree_config = pcall(require, "nvim-tree.config")
  if not status_ok then
    return
  end
  local g = vim.g

  g.nvim_tree_icons = {
    default = "",
    symlink = "",
    git = {
      unstaged = "",
      staged = "",
      unmerged = "",
      renamed = "",
      untracked = "",
      deleted = "",
      ignored = "◌",
    },
    folder = {
      default = "",
      open = "",
      empty = "",
      empty_open = "",
      symlink = "",
    },
  }

  for opt, val in pairs(rvim.nvimtree) do
    g["nvim_tree_" .. opt] = val
  end
  g["root_folder_modifier"] = ":t"

  local tree_cb = nvim_tree_config.nvim_tree_callback

  require 'nvim-tree'.setup {
    auto_close = rvim.nvimtree.setup.auto_close,
    update_cwd = true,
    hijack_cursor = false,
    tree_follow = true,
    update_to_buf_dir   = {
      enable = false,
      auto_open = false,
    },
    view = {
      side = rvim.nvimtree.side,
      mappings = {
      custom_only = false,
      list = {
        -- { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = tree_cb "edit" },
        { key = "l", cb = tree_cb "edit" },
        { key = "h", cb = tree_cb "close_node" },
        { key = "V", cb = tree_cb "vsplit" },
        { key = "N", cb = tree_cb "last_sibling" },
        { key = "I", cb = tree_cb "toggle_dotfiles" },
        { key = "D", cb = tree_cb "dir_up" },
        { key = "gh", cb = tree_cb "toggle_help" },
        }
      }
    },
  }

  local function set_highlights()
    require("core.highlights").all {
      { "NvimTreeIndentMarker", { link = "Comment" } },
      { "NvimTreeNormal", { link = "PanelBackground" } },
      { "NvimTreeEndOfBuffer", { link = "PanelBackground" } },
      { "NvimTreeVertSplit", { link = "PanelVertSplit" } },
      { "NvimTreeStatusLine", { link = "PanelSt" } },
      { "NvimTreeStatusLineNC", { link = "PanelStNC" } },
      { "NvimTreeRootFolder", { gui = "bold,italic", guifg = "LightMagenta" } },
    }
  end

  local tree_view = require "nvim-tree.view"

  local on_open = function()
    if package.loaded["bufferline.state"] and rvim.nvimtree.side == "right" then
      require("bufferline.state").set_offset(rvim.nvimtree.width + 1, "")
    end
  end

  -- Add nvim_tree open callback
  local open = tree_view.open
  tree_view.open = function()
    on_open()
    open()
  end

  local on_close = function()
    local buf = tonumber(vim.fn.expand "<abuf>")
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "NvimTree" and package.loaded["bufferline.state"] then
      require("bufferline.state").set_offset(0)
    end
  end

  rvim.augroup("NvimTreeOverrides", {
    {
      events = { "WinClosed" },
      targets = { "*" },
      command = function()
        on_close()
      end,
    },
    {
      events = { "ColorScheme" },
      targets = { "*" },
      command = function()
        set_highlights()
      end,
    },
    {
      events = { "FileType" },
      targets = { "NvimTree" },
      command = function()
        set_highlights()
      end,
    },
  })
end
