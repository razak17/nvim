return function()
  local g = vim.g
  local nnoremap = rvim.nnoremap

  rvim.nvim_tree = {
    side = "right",
    auto_open = 1,
    auto_close = 1,
    width = 35,
    indent_markers = 1,
    lsp_diagnostics = 0,
    special_files = { "README.md", "Makefile", "MAKEFILE" },
  }

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

  g.nvim_tree_follow = 1
  g.nvim_tree_update_cwd = 1
  g.nvim_tree_respect_buf_cwd = 1
  g.nvim_tree_hijack_cursor = 0
  g.nvim_tree_width_allow_resize = 1
  g.nvim_tree_disable_window_picker = 1
  g.nvim_tree_auto_ignore_ft = { "startify", "dashboard" }
  g.nvim_tree_ignore = { ".git", "node_modules", ".cache", ".DS_Store", "fugitive:" }
  g.root_folder_modifier = ":t"
  g.nvim_tree_side = rvim.nvim_tree.side
  g.nvim_tree_auto_open = rvim.nvim_tree.auto_open
  g.nvim_tree_auto_close = rvim.nvim_tree.auto_close
  g.nvim_tree_width = rvim.nvim_tree.width
  g.nvim_tree_indent_markers = rvim.nvim_tree.indent_markers
  g.nvim_tree_lsp_diagnostics = rvim.nvim_tree.lsp_diagnostics
  g.nvim_tree_special_files = rvim.nvim_tree.special_files

  local action = require("nvim-tree.config").nvim_tree_callback
  g.nvim_tree_bindings = {
    { key = { "<CR>", "o", "<2-LeftMouse>" }, cb = action "edit" },
    { key = "l", cb = action "edit" },
    { key = "h", cb = action "close_node" },
    { key = "V", cb = action "vsplit" },
    { key = "N", cb = action "last_sibling" },
    { key = "I", cb = action "toggle_dotfiles" },
    { key = "D", cb = action "dir_up" },
    { key = "gh", cb = action "toggle_help" },
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

  local on_open = function()
    if package.loaded["bufferline.state"] and rvim.nvimtree.side == "right" then
      require("bufferline.state").set_offset(rvim.nvimtree.width + 1, "")
    end
  end

  local on_close = function()
    local buf = tonumber(vim.fn.expand "<abuf>")
    local ft = vim.api.nvim_buf_get_option(buf, "filetype")
    if ft == "NvimTree" and package.loaded["bufferline.state"] then
      require("bufferline.state").set_offset(0)
    end
  end

  local tree_view = require "nvim-tree.view"

  -- Add nvim_tree open callback
  local open = tree_view.open
  tree_view.open = function()
    on_open()
    open()
  end

  -- Mappings
  nnoremap("<Leader>cr", ":NvimTreeRefresh<CR>")
  nnoremap("<Leader>cv", ":NvimTreeToggle<CR>")
  nnoremap("<Leader>cf", ":NvimTreeFindFile<CR>")
  nnoremap("<Leader>cc", ":NvimTreeClose<CR>")

  rvim.augroup("NvimTreeOverrides", {
    {
      events = { "WinClosed" },
      targets = { "*" },
      command = on_close,
    },
    {
      events = { "ColorScheme" },
      targets = { "*" },
      command = set_highlights,
    },
    {
      events = { "FileType" },
      targets = { "NvimTree" },
      command = set_highlights,
    },
  })
end
