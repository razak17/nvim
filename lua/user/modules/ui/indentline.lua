return function()
  require("indent_blankline").setup {
    char = "│", -- ┆ ┊ 
    show_foldtext = false,
    context_char = "┃",
    show_current_context = true,
    show_current_context_start = false,
    show_current_context_start_on_current_line = false,
    show_first_indent_level = true,
    filetype_exclude = {
      "dap-repl",
      "startify",
      "dashboard",
      "log",
      "fugitive",
      "gitcommit",
      "packer",
      "vimwiki",
      "markdown",
      "json",
      "txt",
      "vista",
      "help",
      "NvimTree",
      "git",
      "TelescopePrompt",
      "undotree",
      "flutterToolsOutline",
      "norg",
      "org",
      "orgagenda",
      "", -- for all buffers without a file type
    },
    buftype_exclude = { "terminal", "nofile" },
    context_patterns = {
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
    },
  }
  -- because lazy load indent-blankline so need read this autocmd
  vim.cmd "autocmd CursorMoved * IndentBlanklineRefresh"
end
