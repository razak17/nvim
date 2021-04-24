vim.g.nvim_tree_side = 'right'
vim.g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
vim.g.nvim_tree_quit_on_open = 0
vim.g.nvim_tree_hide_dotfiles = 0
vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_bindings = {
  ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
  ["h"] = ":lua require'nvim-tree'.on_keypress('close_node')<CR>",
  ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
  ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>"
}
vim.g.nvim_tree_icons = {
  default = '',
  symlink = '',
  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★"
  }
}
