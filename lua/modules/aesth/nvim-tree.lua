local g = vim.g

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
local toggle_tree = function()
  local view_status_ok, view = pcall(require, "nvim-tree.view")
  if not view_status_ok then
    return
  end
  if view.win_open() then
    require("nvim-tree").close()
    if package.loaded["bufferline.state"] then
      require("bufferline.state").set_offset(0)
    end
  else
    if package.loaded["bufferline.state"] and rvim.nvim_tree.side == "right" then
      require("bufferline.state").set_offset(31, "")
    end
    require("nvim-tree").toggle()
  end
end

rvim.nnoremap("<leader>cv", function()
  toggle_tree()
end)

rvim.augroup("NvimTreeOverrides", {
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
