local config = {}

function config.galaxyline()
  require "modules.aesth.statusline"
end

function config.nvim_bufferline()
  require "modules.aesth.bufferline"
end

function config.dashboard()
  require "modules.aesth.dashboard"
end

function config.nvim_tree()
  require "modules.aesth.nvim-tree"
end

function config.gitsigns()
  vim.cmd [[packadd plenary.nvim]]
  require("gitsigns").setup {
    signs = {
      add = { hl = "GitGutterAdd", text = "▋" },
      change = { hl = "GitGutterChange", text = "▋" },
      delete = { hl = "GitGutterDelete", text = "▋" },
      topdelete = { hl = "GitGutterDeleteChange", text = "▔" },
      changedelete = { hl = "GitGutterChange", text = "▎" },
    },
    keymaps = {
      -- Default keymap options
      noremap = true,
      buffer = true,

      ["n ]g"] = {
        expr = true,
        "&diff ? ']g' : '<cmd>lua require\"gitsigns\".next_hunk()<CR>'",
      },
      ["n [g"] = {
        expr = true,
        "&diff ? '[g' : '<cmd>lua require\"gitsigns\".prev_hunk()<CR>'",
      },
      ["n <leader>hs"] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
      ["n <leader>hu"] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
      ["n <leader>hr"] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
      ["n <leader>he"] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
      ["n <leader>hb"] = '<cmd>lua require"gitsigns".blame_line()<CR>',
      ["n <leader>ht"] = '<cmd>lua require"gitsigns".toggle_current_line_blame()<CR>',

      -- Text objects
      ["o ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>',
      ["x ih"] = ':<C-U>lua require"gitsigns".text_object()<CR>',
    },
  }
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
  vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
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
  vim.cmd "autocmd CursorMoved * IndentBlanklineRefresh"
end

return config
