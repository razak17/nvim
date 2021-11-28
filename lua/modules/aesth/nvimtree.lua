return function()
  local status_ok, nvim_tree = rvim.safe_require "nvim-tree"
  if not status_ok then
    return
  end

  local nvim_tree_config = require "nvim-tree.config"
  local tree_cb = nvim_tree_config.nvim_tree_callback

  rvim.nvimtree = {
    setup = {
      open_on_setup = false,
      auto_close = true,
      open_on_tab = false,
      tree_follow = true,
      hijack_cursor = true,
      ignore_ft_on_setup = {
        "startify",
        "dashboard",
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      update_to_buf_dir = {
        enable = false,
        auto_open = false,
        ignore_list = {},
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
      view = {
        width = 30,
        side = "right",
        auto_resize = true,
        hide_root_folder = false,
        mappings = {
          custom_only = false,
        },
      },
      git = {
        enable = false,
        ignore = true,
        timeout = 500,
      },
      hide_dotfiles = false,
      ignore = { ".git", "node_modules", ".cache", ".DS_Store", "fugitive:" },
    },
    defaults = {
      show_icons = {
        git = 0,
        folders = 1,
        files = 1,
        folder_arrows = 0,
        tree_width = 30,
      },
      indent_markers = 1,
      quit_on_open = 0,
      disable_window_picker = 1,
      root_folder_modifier = ":t",
      git_hl = 1,
      icons = {
        default = "",
        symlink = "",
        git = {
          unstaged = "",
          staged = "S",
          unmerged = "",
          renamed = "➜",
          untracked = "U",
          deleted = "",
          ignored = "◌",
        },
        folder = {
          arrow_open = "",
          arrow_closed = "",
          default = "",
          open = "",
          empty = "",
          empty_open = "",
          symlink = "",
        },
      },
    },
  }

  for opt, val in pairs(rvim.nvimtree.defaults) do
    vim.g["nvim_tree_" .. opt] = val
  end

  -- Implicitly update nvim-tree when project module is active
  if rvim.plugin.project.active then
    rvim.nvimtree.defaults.respect_buf_cwd = 1
    rvim.nvimtree.setup.update_cwd = true
    rvim.nvimtree.setup.disable_netrw = false
    rvim.nvimtree.setup.hijack_netrw = false
    vim.g.netrw_banner = false
  end

  if not rvim.nvimtree.setup.view.mappings.list then
    rvim.nvimtree.setup.view.mappings.list = {
      { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = tree_cb "edit" },
      { key = "l", cb = tree_cb "edit" },
      { key = "h", cb = tree_cb "close_node" },
      { key = "V", cb = tree_cb "vsplit" },
      { key = "N", cb = tree_cb "last_sibling" },
      { key = "I", cb = tree_cb "toggle_dotfiles" },
      { key = "D", cb = tree_cb "dir_up" },
      { key = "gh", cb = tree_cb "toggle_help" },
      { key = "cd", cb = tree_cb "cd" },
    }
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
