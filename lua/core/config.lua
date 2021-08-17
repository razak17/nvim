local g = vim.g

-- common
rvim.common = {
  leader = "space",
  transparent_window = false,
  line_wrap_cursor_movement = true,
  format_on_save = true,
  debug = false,
}

rvim.log = {
  ---@usage can be { "trace", "debug", "info", "warn", "error", "fatal" },
  level = "warn",
  viewer = {
    ---@usage this will fallback on "less +F" if not found
    cmd = "lnav",
    layout_config = {
      ---@usage direction = 'vertical' | 'horizontal' | 'window' | 'float',
      direction = "horizontal",
      open_mapping = "",
      size = 40,
      float_opts = {},
    },
  },
}

-- opts
rvim.sets = {
  wrap = false,
  spell = false,
  spelllang = "en",
  textwidth = 100,
  tabstop = 2,
  cmdheight = 2,
  shiftwidth = 2,
  numberwidth = 4,
  scrolloff = 7,
  laststatus = 2,
  showtabline = 2,
  smartcase = true,
  ignorecase = true,
  hlsearch = true,
  timeoutlen = 500,
  foldenable = true,
  foldtext = "v:lua.folds()",
  udir = vim.g.cache_dir .. "/undodir",
  viewdir = vim.g.cache_dir .. "view",
  directory = vim.g.cache_dir .. "/swap",
}

rvim.lsp = {
  document_highlight = true,
  hover_diagnostics = true,
  lint_on_save = true,
  popup_border = "single",
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "LspDiagnosticsSignError", text = "" },
        { name = "LspDiagnosticsSignWarning", text = "" },
        { name = "LspDiagnosticsSignHint", text = "" },
        { name = "LspDiagnosticsSignInformation", text = "" },
      },
    },
    virtual_text = {
      prefix = "",
      spacing = 0,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    smart_cwd = true,
  },
  binary = {
    clangd = g.lspinstall_dir .. "/cpp/clangd/bin/clangd",
    cmake = g.lspinstall_dir .. "/cmake/venv/bin/cmake-language-server",
    css = g.lspinstall_dir .. "/css/vscode-css/css-language-features/server/dist/node/cssServerMain.js",
    docker = g.lspinstall_dir .. "/dockerfile/node_modules/.bin/docker-langserver",
    elixir = g.lspinstall_dir .. "/elixir/elixir-ls/language_server.sh",
    go = g.lspinstall_dir .. "/go/gopls",
    graphql = "graphql-lsp",
    lua = g.sumneko_root_path .. "/sumneko-lua-language-server",
    html = g.lspinstall_dir .. "/html/vscode-html/html-language-features/server/dist/node/htmlServerMain.js",
    json = g.lspinstall_dir .. "/json/vscode-json/json-language-features/server/dist/node/jsonServerMain.js",
    python = g.lspinstall_dir .. "/python/node_modules/.bin/pyright-langserver",
    rust = g.lspinstall_dir .. "/rust/rust-analyzer",
    sh = g.lspinstall_dir .. "/bash/node_modules/.bin/bash-language-server",
    tsserver = g.lspinstall_dir .. "/typescript/node_modules/.bin/typescript-language-server",
    vim = g.lspinstall_dir .. "/vim/node_modules/.bin/vim-language-server",
    yaml = g.lspinstall_dir .. "/yaml/node_modules/.bin/yaml-language-server",
  },
}
