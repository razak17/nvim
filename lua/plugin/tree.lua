local vim = vim
local g = vim.g
local mappings = require('utils.map')
local nnoremap = mappings.nnoremap

g.nvim_tree_side = 'right' -- left by default
g.nvim_tree_width = 30 -- 30 by default
g.nvim_tree_ignore = { '.git', 'node_modules', '.cache' } -- empty by default
g.nvim_tree_auto_open = 0 -- 0 by default, opens the tree when typing `vim $DIR` or `vim`
g.nvim_tree_auto_close = 0 -- 0 by default, closes the tree when it's the last window
g.nvim_tree_quit_on_open = 0 -- 1 by default, closes the tree when you open a file
g.nvim_tree_follow = 1 -- 0 by default, this option allows the cursor to be updated when entering a buffer
g.nvim_tree_indent_markers = 1 -- 0 by default, this option shows indent markers when folders are open
g.nvim_tree_hide_dotfiles = 0 -- 0 by default, this option hides files and folders starting with a dot `.`
g.nvim_tree_git_hl = 1 -- 0 by default, will enable file highlight for git attributes (can be used without the icons).
g.nvim_tree_root_folder_modifier = ':~' -- This is the default. See :help filename-modifiers for more options
g.nvim_tree_tab_open = 1 -- 0 by default, will open the tree when entering a new tab and the tree was previously open
g.nvim_tree_width_allow_resize  = 1 -- 0 by default, will not resize the tree when opening a file
g.nvim_tree_show_icons = {
  git = 1,
  folders = 1,
  files = 1,
}

--[[ g.nvim_tree_bindings = {
  edit = { '<CR>', 'o' },
  edit_vsplit = '<C-v>',
  edit_split  = '<C-x>',
  edit_tab = '<C-e>',
  close_node = { '<S-CR>', '<BS>' },
  toggle_ignored = 'I',
  toggle_dotfiles = 'H',
  refresh = 'R',
  preview = '<Tab>',
  cd = '<C-[>',
  create = 'a',
  remove = 'd',
  rename = 'r',
  cut = 'x',
  copy = 'c',
  paste = 'p',
  prev_git_item = '[c',
  next_git_item = ']c',
} ]]

g.nvim_tree_icons = {
  default =  '',
  symlink = '',
  git = {
    unstaged = "✗",
    staged = "✓",
    unmerged = "",
    renamed = "➜",
    untracked = "★"
  },
  folder = {
    default = "",
    open = "",
    symlink = "",
  }
}

-- binds
nnoremap('<Leader>cv', ':NvimTreeToggle<CR>')
nnoremap('<Leader>cr', ':NvimTreeRefresh<CR>')
nnoremap('<Leader>cf', ':NvimTreeFindFile<CR>')

vim.cmd[[ highlight NvimTreeFolderIcon guibg=yellow ]]


