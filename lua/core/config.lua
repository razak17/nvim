local g = vim.g

-- common
rvim.common = {
  leader = "space",
  transparent_window = false,
  line_wrap_cursor_movement = true,
  format_on_save = true,
  debug = false,
}

-- Consistent store of various UI items to reuse throughout my config
rvim.style = {
  icons = {
    error = "",
    warn = "",
    info = "",
    hint = "",
  },
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
  bookmarks = { active = false },
  colorizer = { active = true },
  undotree = { active = false },
  fugitive = { active = false },
  rooter = { active = true },
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
  document_highlight = true,
  hover_diagnostics = true,
  lint_on_save = true,
  popup_border = "single",
  diagnostics = {
    signs = {
      active = true,
      values = {
        { name = "LspDiagnosticsSignError", text = rvim.style.icons.error },
        { name = "LspDiagnosticsSignWarning", text = rvim.style.icons.warn },
        { name = "LspDiagnosticsSignHint", text = rvim.style.icons.hint },
        { name = "LspDiagnosticsSignInformation", text = rvim.style.icons.info },
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
    clangd = "clangd",
    cmake = "cmake-language-server",
    css = "vscode-css-language-server",
    docker = "docker-langserver",
    efm = "efm-langserver",
    elixir = g.elixirls_root_path .. "/.bin/language_server.sh",
    graphql = "graphql-lsp",
    lua = g.sumneko_root_path .. "/bin/Linux/lua-language-server",
    go = "gopls",
    html = "vscode-html-language-server",
    json = "vscode-json-language-server",
    python = "pyright-langserver",
    rust = "rust-analyzer",
    sh = "bash-language-server",
    tsserver = "typescript-language-server",
    vim = "vim-language-server",
    yaml = "yaml-language-server",
  },
}
