return function()
  vim.g.indent_blankline_char = "│"
  vim.g.indent_blankline_show_first_indent_level = true
  vim.g.indent_blankline_filetype_exclude = {
    "dashboard",
    "log",
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
    "dap-repl",
    "", -- for all buffers without a file type
  }
  vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
  vim.g.indent_blankline_show_trailing_blankline_indent = false
  vim.g.indent_blankline_show_current_context = true
  vim.g.show_current_context_start_on_current_line = false
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
