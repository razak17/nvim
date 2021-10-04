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

-- toogle plugins easily
rvim.plugin = {
  -- SANE defaults
  SANE = { active = true },
  -- debug
  debug = { active = false },
  debug_ui = { active = false },
  dap_install = { active = false },
  osv = { active = false },
  -- lsp
  saga = { active = false },
  lightbulb = { active = true },
  symbols_outline = { active = false },
  bqf = { active = false },
  trouble = { active = false },
  nvim_lint = { active = false },
  formatter = { active = false },
  lsp_ts_utils = { active = true },
  -- treesitter
  treesitter = { active = false },
  playground = { active = true },
  rainbow = { active = false },
  matchup = { active = false },
  autotag = { active = false },
  autopairs = { active = true },
  -- editor
  fold_cycle = { active = false },
  accelerated_jk = { active = false },
  easy_align = { active = true },
  cool = { active = true },
  delimitmate = { active = false },
  eft = { active = false },
  cursorword = { active = false },
  surround = { active = true },
  dial = { active = true },
  -- tools
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = true },
  colorizer = { active = true },
  undotree = { active = false },
  fugitive = { active = false },
  project = { active = true },
  diffview = { active = true },
  -- TODO: handle these later
  glow = { active = false },
  doge = { active = false },
  dadbod = { active = false },
  restconsole = { active = false },
  markdown_preview = { active = true },
  -- aesth
  tree = { active = true },
  dashboard = { active = false },
  statusline = { active = false },
  git_signs = { active = false },
  indent_line = { active = false },
  -- completion
  emmet = { active = false },
  friendly_snippets = { active = true },
  vsnip = { active = true },
  telescope_fzy = { active = false },
  telescope_project = { active = false },
  telescope_media_files = { active = false },
}

rvim.lsp = {
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
  completion = {
    item_kind = {
      "   (Text) ",
      "   (Method)",
      " ƒ  (Function)",
      "   (Constructor)",
      " ﴲ  (Field)",
      "   (Variable)",
      "   (Class)",
      " ﰮ  (Interface)",
      "   (Module)",
      " 襁 (Property)",
      "   (Unit)",
      "   (Value)",
      " 了 (Enum)",
      "   (Keyword)",
      "   (Snippet)",
      "   (Color)",
      "   (File)",
      "   (Reference)",
      "   (Folder)",
      "   (EnumMember)",
      "   (Constant)",
      " ﳤ  (Struct)",
      " 鬒 (Event)",
      "   (Operator)",
      "   (TypeParameter)",
    },
  },
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
      spacing = 2,
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    smart_cwd = true,
  },
  document_highlight = true,
  hover_diagnostics = true,
  lint_on_save = true,
  popup_border = "single",
}
