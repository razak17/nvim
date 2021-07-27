local config = {}

function config.galaxyline() require('modules.aesth.statusline') end

function config.nvim_bufferline() require('modules.aesth.bufferline') end

function config.dashboard() require('modules.aesth.dashboard') end

function config.gitsigns()
  vim.cmd [[packadd plenary.nvim]]
  require('gitsigns').setup {
    signs = {
      add = {hl = 'GitGutterAdd', text = '▋'},
      change = {hl = 'GitGutterChange', text = '▋'},
      delete = {hl = 'GitGutterDelete', text = '▋'},
      topdelete = {hl = 'GitGutterDeleteChange', text = '▔'},
      changedelete = {hl = 'GitGutterChange', text = '▎'},
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ['n ]g'] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ['n [g'] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ['n <leader>hs'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ['n <leader>hu'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ['n <leader>hr'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ['n <leader>he'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ['n <leader>hb'] = '<cmd>lua require"gitsigns".blame_line()<CR>',
      ['n <leader>ht'] = '<cmd>lua require"gitsigns".toggle_current_line_blame()<CR>',

      -- Text objects
      ['o ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ['x ih'] = ':<C-U>lua require"gitsigns".text_object()<CR>',
    },
  }
end

function config.nvim_tree()
  local g = vim.g
  local tree_cb = require'nvim-tree.config'.nvim_tree_callback
  vim.cmd [[packadd nvim-web-devicons]]
  -- On Ready Event for Lazy Loading work
  require("nvim-tree.events").on_nvim_tree_ready(function()
    vim.cmd("NvimTreeRefresh")
  end)
  g.nvim_tree_side = rvim.nvim_tree.side
  g.nvim_tree_ignore = {'.git', 'node_modules', '.cache'}
  g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'}
  g.nvim_tree_auto_open = rvim.nvim_tree.auto_open
  g.nvim_tree_follow = 1
  g.nvim_tree_width = rvim.nvim_tree.width
  g.nvim_tree_indent_markers = rvim.nvim_tree.indent_markers
  g.nvim_tree_width_allow_resize = 1
  g.nvim_tree_lsp_diagnostics = rvim.nvim_tree.lsp_diagnostics
  g.nvim_tree_disable_window_picker = 1
  g.nvim_tree_special_files = rvim.nvim_tree.special_files
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
end

function config.indent_blankline()
  vim.g.indent_blankline_char = "│"
  vim.g.indent_blankline_show_first_indent_level = true
  vim.g.indent_blankline_filetype_exclude = {
    "dashboard",
    "log",
    "fugitive",
    "gitcommit",
    "packer",
    "markdown",
    "json",
    "txt",
    "outline",
    "help",
    "NvimTree",
    "git",
    "TelescopePrompt",
    "undotree",
    "", -- for all buffers without a file type
  }
  vim.g.indent_blankline_buftype_exclude = {"terminal", "nofile"}
  vim.g.indent_blankline_show_trailing_blankline_indent = false
  vim.g.indent_blankline_show_current_context = true
  vim.g.indent_blankline_context_patterns = {
    "class",
    "function",
    "method",
    "block",
    "list_literal",
    "selector",
    "^if",
    "^table",
    "if_statement",
    "while",
    "for",
  }
  -- because lazy load indent-blankline so need read this autocmd
  vim.cmd('autocmd CursorMoved * IndentBlanklineRefresh')
end

return config
