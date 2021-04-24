local config = {}

function config.galaxyline()
  require('modules.aesth.statusline')
end

function config.nvim_bufferline()
  require('modules.aesth.bufferline')
end

function config.dashboard()
  require('modules.aesth.dashboard')
end

function config.gitsigns()
  require('modules.aesth.git_signs')
end

function config.nvim_tree()
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
end

function config.bg()
  vim.cmd [[ colo zephyr ]]
  vim.cmd [[ autocmd ColorScheme * highlight clear SignColumn ]]
  vim.cmd [[ autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE ]]
  vim.cmd [[ hi ColorColumn ctermbg=lightgrey ]]
  vim.cmd [[ hi LineNr ctermbg=NONE guibg=NONE ]]
  vim.cmd [[ hi Comment cterm=italic ]]
end

function config.ColorMyPencils()
  vim.cmd [[ hi ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi Normal guibg=none ]]
  vim.cmd [[ hi LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi TelescopeBorder guifg=#aeacec ]]
  vim.cmd [[ hi FloatermBorder guifg= #aeacec ]]
  vim.cmd [[ hi WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi WhichKeyDesc guifg=#4dd2dc  ]]
end

return config

