-- opts
core.sets = {
  wrap = false,
  spell = false,
  spelllang = "en",
  textwidth = 80,
  number = true,
  relative_number = true,
  numberwidth = 4,
  shiftwidth = 2,
  tabstop = 2,
  cmdheight = 2,
  scrolloff = 7,
  laststatus = 2,
  showtabline = 2,
  smartcase = true,
  ignorecase = true,
  hlsearch = true,
  timeoutlen = 500,
  foldenable = true,
  foldtext = 'v:lua.folds()',
  udir = core.__cache_dir .. 'undodir',
  viewdir = core.__cache_dir .. 'view',
  directory = core.__cache_dir .. 'swap',
}

core.plugin = {
  -- SANE defaults
  SANE = {active = true},
  -- debug
  debug = {active = false},
  debug_ui = {active = false},
  dap_install = {active = false},
  osv = {active = false},
  -- lsp
  saga = {active = false},
  lightbulb = {active = false},
  symbols_outline = {active = false},
  bqf = {active = false},
  trouble = {active = false},
  -- treesitter
  treesitter = {active = true},
  rainbow = {active = false},
  matchup = {active = false},
  autotag = {active = false},
  autopairs = {active = false},
  -- editor
  doge = {active = false},
  fold_cycle = {active = false},
  accelerated_jk = {active = true},
  easy_align = {active = false},
  cool = {active = true},
  delimitmate = {active = false},
  eft = {active = false},
  cursorword = {active = false},
  surround = {active = true},
  dial = {active = false},
  -- tools
  fterm = {active = true},
  far = {active = false},
  bookmarks = {active = false},
  colorizer = {active = false},
  undotree = {active = false},
  fugitive = {active = false},
  glow = {active = false},
  dadbod = {active = false},
  restconsole = {active = false},
  markdown_preview = {active = false},
  -- aesth
  tree = {active = false},
  dashboard = {active = false},
  statusline = {active = true},
  git_signs = {active = false},
  indent_line = {active = false},
  -- completion
  emmet = {active = false},
  telescope_fzy = {active = false},
  telescope_project = {active = false},
  telescope_media_files = {active = false},
}

core.telescope = {
  prompt_prefix = " ❯ ",
  layout_config = {height = 0.9, width = 0.9},
  borderchars = {'─', '│', '─', '│', '┌', '┐', '┘', '└'},
}

core.nvim_tree = {
  side = 'right',
  auto_open = 0,
  width = 35,
  indent_markers = 1,
  lsp_diagnostics = 0,
  special_files = {'README.md', 'Makefile', 'MAKEFILE'},
}

core.treesitter = {
  ensure_installed = {
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "graphql",
    "jsdoc",
    "json",
    "yaml",
    "go",
    "c",
    "dart",
    "cpp",
    "rust",
    "python",
    "bash",
    "lua",
  },
  highlight = {enabled = true},
}

core.which_key = {separator = ''}

core.dashboard = {
  custom_header = {
    "                                                       ",
    "                                                       ",
    " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
    " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
    " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
    " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
    " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
    " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
    "                                                       ",
    "                                                       ",
  },
  default_executive = 'telescope',
  disable_statusline = 0,
  save_session = function() vim.cmd("SessionSave") end,
  session_directory = core.__session_dir,
}

core.utils = {
  leader_key = " ",
  dapinstall_dir = core.__data_dir,
  transparent_window = false,
}

core.lsp = {
  hoverdiagnostics = true,
  format_on_save = true,
  document_highlight = true,
  popup_border = "single",
  diagnostics = {
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {spacing = 0, prefix = ""},
  },
}
