local g = vim.g

-- common
rvim.common = {
  leader = "space",
  transparent_window = false,
  line_wrap_cursor_movement = false,
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
  SANE = { active = false },
  -- debug
  debug = { active = false },
  debug_ui = { active = false },
  dap_install = { active = false },
  osv = { active = false },
  -- lsp
  lspconfig = { active = true },
  lsp_installer = { active = true },
  fix_cursorhold = { active = true },
  nlsp= { active = true },
  null_ls = { active = true },
  saga = { active = false },
  lightbulb = { active = false },
  symbols_outline = { active = false },
  bqf = { active = false },
  trouble = { active = false },
  nvim_lint = { active = false },
  formatter = { active = false },
  lsp_ts_utils = { active = false },
  -- treesitter
  treesitter = { active = true },
  playground = { active = true },
  rainbow = { active = false },
  matchup = { active = false },
  autotag = { active = true },
  autopairs = { active = false },
  -- editor
  fold_cycle = { active = true },
  ajk = { active = true },
  easy_align = { active = true },
  cool = { active = true },
  delimitmate = { active = false },
  eft = { active = false },
  cursorword = { active = false },
  surround = { active = true },
  dial = { active = false },
  colorizer = { active = true },
  kommentary = { active = true },
  -- tools
  fterm = { active = true },
  far = { active = true },
  bookmarks = { active = true },
  undotree = { active = true },
  fugitive = { active = false },
  project = { active = false },
  diffview = { active = false },
  -- TODO: handle these later
  glow = { active = false },
  doge = { active = false },
  dadbod = { active = false },
  restconsole = { active = false },
  markdown_preview = { active = false },
  -- aesth
  tree = { active = true },
  dashboard = { active = true },
  statusline = { active = true },
  bufferline = { active = true },
  devicons = { active = true },
  git_signs = { active = false },
  indent_line = { active = false },
  -- completion
  which_key = { active = true },
  plenary = { active = true },
  popup = { active = true },
  telescope = { active = true },
  compe = { active = true },
  vsnip = { active = true },
  emmet = { active = false },
  friendly_snippets = { active = true },
  telescope_fzy = { active = false },
  telescope_project = { active = false },
  telescope_media_files = { active = false },
}

-- Consistent store of various UI items to reuse throughout my config
rvim.style = {
  palette = {
    pale_red = "#E06C75",
    dark_red = "#be5046",
    light_red = "#c43e1f",
    dark_orange = "#FF922B",
    green = "#98c379",
    bright_yellow = "#FAB005",
    light_yellow = "#e5c07b",
    dark_blue = "#4e88ff",
    magenta = "#c678dd",
    comment_grey = "#5c6370",
    grey = "#3E4556",
    whitesmoke = "#626262",
    bright_blue = "#51afef",
    teal = "#15AABF",
    highlight_bg = "#4E525C",
  },
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
  colors = {
    error =rvim.style.palette.pale_red,
    warn = rvim.style.palette.dark_orange,
    hint = rvim.style.palette.bright_yellow,
    info = rvim.style.palette.teal,
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
      active = false,
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
    underline = false,
    update_in_insert = false,
    severity_sort = false,
    smart_cwd = false,
  },
  document_highlight = true,
  code_lens_refresh = true,
  hover_diagnostics = true,
  lint_on_save = false,
  popup_border = "single",
}
