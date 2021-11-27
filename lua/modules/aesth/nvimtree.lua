return function()
  local status_ok, nvim_tree = rvim.safe_require "nvim-tree"
  if not status_ok then
    return
  end

  local nvim_tree_config = require "nvim-tree.config"

  local tree_cb = nvim_tree_config.nvim_tree_callback

  rvim.nvimtree = {
    defaults = {
      width = 35,
      indent_markers = 1,
      special_files = { "README.md", "Makefile", "MAKEFILE" },
      ignore = { ".git", "node_modules", ".cache", ".DS_Store", "fugitive:" },
      respect_buf_cwd = 1,
      width_allow_resize = 1,
      disable_window_picker = 1,
      root_folder_modifier = ":t",
      auto_ignore_ft = { "startify", "dashboard" },
      icons = {
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
      },
    },
    setup = {
      auto_close = true,
      update_cwd = true,
      hijack_cursor = true,
      disable_netrw = true,
      hijack_netrw = true,
      open_on_setup = true,
      tree_follow = true,
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      diagnostics = {
        enable = true,
        icons = {
          hint = "",
          info = "",
          warning = "",
          error = "",
        },
      },
      update_to_buf_dir = {
        enable = false,
        auto_open = false,
        ignore_list = {},
      },
      view = {
        side = "right",
        auto_resize = true,
        hide_root_folder = false,
        mappings = {
          custom_only = false,
          list = {
            { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = tree_cb "edit" },
            { key = "l", cb = tree_cb "edit" },
            { key = "h", cb = tree_cb "close_node" },
            { key = "V", cb = tree_cb "vsplit" },
            { key = "N", cb = tree_cb "last_sibling" },
            { key = "I", cb = tree_cb "toggle_dotfiles" },
            { key = "D", cb = tree_cb "dir_up" },
            { key = "gh", cb = tree_cb "toggle_help" },
            { key = "cd", cb = tree_cb "cd" },
          },
        },
      },
    },
  }

  for opt, val in pairs(rvim.nvimtree.defaults) do
    vim.g["nvim_tree_" .. opt] = val
  end

  require("core.highlights").plugin(
    "NvimTree",
    { "NvimTreeIndentMarker", { link = "Comment" } },
    { "NvimTreeNormal", { link = "PanelBackground" } },
    { "NvimTreeNormalNC", { link = "PanelBackground" } },
    { "NvimTreeSignColumn", { link = "PanelBackground" } },
    { "NvimTreeEndOfBuffer", { link = "PanelBackground" } },
    { "NvimTreeVertSplit", { link = "PanelVertSplit" } },
    { "NvimTreeStatusLine", { link = "PanelSt" } },
    { "NvimTreeStatusLineNC", { link = "PanelStNC" } },
    { "NvimTreeRootFolder", { gui = "bold,italic", guifg = "LightMagenta" } }
  )

  nvim_tree.setup(rvim.nvimtree.setup)
end
