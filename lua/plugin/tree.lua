local vim = vim
local g = vim.g
local mappings = require('utils.map')
local nnoremap = mappings.nnoremap

g.nvim_tree_side = 'right'
g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' }
g.nvim_tree_quit_on_open = 0
g.nvim_tree_hide_dotfiles = 1
g.nvim_tree_follow = 1
g.nvim_tree_indent_markers = 1
g.nvim_tree_root_folder_modifier = ':~'
g.nvim_tree_tab_open = 1
g.nvim_tree_width_allow_resize  = 1
g.nvim_tree_indent_markers = 1
g.nvim_tree_show_icons = {
  git = 1,
  folders = 1,
  files = 1,
}
g.nvim_tree_bindings = {
  ["l"] = ":lua require'nvim-tree'.on_keypress('edit')<CR>",
  ["s"] = ":lua require'nvim-tree'.on_keypress('vsplit')<CR>",
  ["i"] = ":lua require'nvim-tree'.on_keypress('split')<CR>",
}
g.nvim_tree_icons = {
  default =  '',
  -- default =  '',
  symlink = '',
  git = {
    -- unstaged = "✗",
    unstaged = "✚",
    staged = "✓",
    -- unmerged = "",
    unmerged =  "≠",
    -- renamed = "➜",
    renamed =  "≫",
    untracked = "★"
  },
}

-- binds
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

vim.cmd[[ highlight NvimTreeFolderIcon guibg=yellow ]]


