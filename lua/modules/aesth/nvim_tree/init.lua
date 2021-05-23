local g = vim.g

vim.cmd [[packadd nvim-web-devicons]]

-- On Ready Event for Lazy Loading work
require("nvim-tree.events").on_nvim_tree_ready(
    function()
      vim.cmd("NvimTreeRefresh")
    end)

g.nvim_tree_side = 'right'
g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'}
g.nvim_tree_follow = 1
g.nvim_tree_width = 35
g.nvim_tree_indent_markers = 1
g.nvim_tree_width_allow_resize = 1
g.nvim_tree_add_trailing = 1
g.nvim_tree_lsp_diagnostics = 1
g.nvim_tree_special_files = {'README.md', 'Makefile', 'MAKEFILE'}
g.nvim_tree_bindings = {
  ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
  ["h"] = ":lua require'nvim-tree'.on_keypress('close_node')<CR>",
  ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
  ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>"
}
g.nvim_tree_icons = {default = ''}
