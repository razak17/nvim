local g = vim.g
local tree_cb = require'nvim-tree.config'.nvim_tree_callback

vim.cmd [[packadd nvim-web-devicons]]

-- On Ready Event for Lazy Loading work
require("nvim-tree.events").on_nvim_tree_ready(function()
  vim.cmd("NvimTreeRefresh")
end)

g.nvim_tree_side = 'right'
g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'}
g.nvim_tree_auto_open = core.nvim_tree.auto_open
g.nvim_tree_follow = 1
g.nvim_tree_width = core.nvim_tree.width
g.nvim_tree_indent_markers = core.nvim_tree.indent_markers
g.nvim_tree_width_allow_resize = 1
g.nvim_tree_lsp_diagnostics = core.nvim_tree.lsp_diagnostics
g.nvim_tree_disable_window_picker = 1
g.nvim_tree_special_files = core.nvim_tree.special_files
g.nvim_tree_hijack_cursor = 0
g.nvim_tree_update_cwd = 1
g.nvim_tree_bindings = {
  {key = {"<CR>", "o", "<2-LeftMouse>"}, cb = tree_cb("edit")},
  {key = "l", cb = tree_cb("edit")},
  {key = "h", cb = tree_cb("close_node")},
  {key = "V", cb = tree_cb("vsplit")},
  {key = "N", cb = tree_cb("last_sibling")},
  {key = "I", cb = tree_cb("toggle_dotfiles")},
  {key = "D", cb = tree_cb("dir_up")},
  {key = "gh", cb = tree_cb("toggle_help")},
}
g.nvim_tree_icons = {default = ''}
