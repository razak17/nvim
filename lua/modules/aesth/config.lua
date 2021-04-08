local config = {}

function config.galaxyline()
  require('modules.aesth.statusline.eviline')
end

function config.nvim_bufferline()
  require('modules.aesth.bufferline')
end

function config.dashboard()
  require('modules.aesth.dashboard')
end

function config._gitsigns()
  require('gitsigns').setup {
    signs = {
      add = {hl = 'GitGutterAdd', text = '▋'},
      change = {hl = 'GitGutterChange', text = '▋'},
      delete = {hl = 'GitGutterDelete', text = '▋'},
      topdelete = {hl = 'GitGutterDeleteChange', text = '▔'},
      changedelete = {hl = 'GitGutterChange', text = '▎'}
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ['n ]g'] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'"
      },
      ['n [g'] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'"
      },

      ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ['n <leader>hp'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',

      -- Text objects
      ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>'
    }
  }
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

  vim.cmd [[ highlight NvimTreeFolderIcon guibg=NONE ]]
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

