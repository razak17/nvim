-- opts
rvim.sets = {
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
  foldtext = "v:lua.folds()",
  udir = rvim.__cache_dir .. "/undodir",
  viewdir = rvim.__cache_dir .. "/view",
  directory = rvim.__cache_dir .. "/swap",
}

rvim.plugin = {
  -- SANE defaults
  SANE = {active = true},
  -- debug
  debug = {active = false},
  debug_ui = {active = false},
  dap_install = {active = false},
  osv = {active = false},
  -- lsp
  saga = {active = false},
  lightbulb = {active = true},
  symbols_outline = {active = false},
  bqf = {active = false},
  trouble = {active = false},
  nvim_lint = {active = true},
  formatter = {active = true},
  lsp_ts_utils = {active = true},
  -- treesitter
  treesitter = {active = false},
  playground = {active = true},
  rainbow = {active = false},
  matchup = {active = false},
  autotag = {active = false},
  autopairs = {active = true},
  -- editor
  fold_cycle = {active = false},
  accelerated_jk = {active = false},
  easy_align = {active = false},
  cool = {active = true},
  delimitmate = {active = false},
  eft = {active = false},
  cursorword = {active = true},
  surround = {active = true},
  dial = {active = true},
  -- tools
  fterm = {active = true},
  far = {active = true},
  bookmarks = {active = false},
  colorizer = {active = true},
  undotree = {active = false},
  fugitive = {active = false},
  rooter = {active = true},
  -- TODO: handle these later
  glow = {active = false},
  doge = {active = false},
  dadbod = {active = false},
  restconsole = {active = false},
  markdown_preview = {active = true},
  -- aesth
  tree = {active = true},
  dashboard = {active = false},
  statusline = {active = false},
  git_signs = {active = false},
  indent_line = {active = false},
  -- completion
  emmet = {active = false},
  friendly_snippets = {active = true},
  vsnip = {active = true},
  telescope_fzy = {active = false},
  telescope_project = {active = false},
  telescope_media_files = {active = false},
}

rvim.telescope = {
  prompt_prefix = " ❯ ",
  layout_config = {height = 0.9, width = 0.9},
  borderchars = {"─", "│", "─", "│", "┌", "┐", "┘", "└"},
}

rvim.nvim_tree = {
  side = "right",
  auto_open = 0,
  width = 35,
  indent_markers = 1,
  lsp_diagnostics = 0,
  special_files = {"README.md", "Makefile", "MAKEFILE"},
}

rvim.treesitter = {
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

rvim.dashboard = {
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
  default_executive = "telescope",
  disable_statusline = 0,
  save_session = function()
    vim.cmd("SessionSave")
  end,
  session_directory = rvim.__session_dir,
}

rvim.utils = {leader_key = " ", dapinstall_dir = rvim.__data_dir, transparent_window = false}

local g = vim.g
rvim.lsp = {
  override = {},
  document_highlight = true,
  hover_diagnostics = true,
  format_on_save = true,
  lint_on_save = true,
  rust_tools = false,
  on_attach_callback = nil,
  binary = {
    clangd = g.lspinstall_dir .. "/cpp/clangd/bin/clangd",
    cmake = g.lspinstall_dir .. "/cmake/venv/bin/cmake-language-server",
    css = g.lspinstall_dir ..
      "/css/vscode-css/css-language-features/server/dist/node/cssServerMain.js",
    docker = g.lspinstall_dir .. "/dockerfile/node_modules/.bin/docker-langserver",
    elixir = g.lspinstall_dir .. "/elixir/elixir-ls/language_server.sh",
    go = g.lspinstall_dir .. "/go/gopls",
    graphql = "graphql-lsp",
    lua = g.sumneko_root_path .. "/sumneko-lua-language-server",
    html = g.lspinstall_dir ..
      "/html/vscode-html/html-language-features/server/dist/node/htmlServerMain.js",
    json = g.lspinstall_dir ..
      "/json/vscode-json/json-language-features/server/dist/node/jsonServerMain.js",
    python = g.lspinstall_dir .. "/python/node_modules/.bin/pyright-langserver",
    rust = g.lspinstall_dir .. "/rust/rust-analyzer",
    sh = g.lspinstall_dir .. "/bash/node_modules/.bin/bash-language-server",
    tsserver = g.lspinstall_dir .. "/typescript/node_modules/.bin/typescript-language-server",
    vim = g.lspinstall_dir .. "/vim/node_modules/.bin/vim-language-server",
    yaml = g.lspinstall_dir .. "/yaml/node_modules/.bin/yaml-language-server",
  },
}
