--------------------------------------------------------------------------------
-- Global namespace
--------------------------------------------------------------------------------
local env = vim.env

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  animation = { enable = false },
  apps = {
    image = 'sxiv',
    pdf = 'zathura',
    audio = 'mpv',
    video = 'mpv',
    web = 'firefox',
    explorer = 'thunar',
  },
  autosave = { enable = true },
  debug = { enable = false },
  frecency = { enable = true },
  git = {},
  use_local_gx = false,
  media = {
    audio = { 'mp3', 'm4a' },
    doc = { 'pdf' },
    image = { 'jpg', 'png', 'jpeg', 'ico', 'gif' },
    video = { 'mp4', 'mkv' },
  },
  lsp = {
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'denols', 'emmet_ls', 'pyright', 'ruff_lsp', 'vtsls' },
    },
    enable = env.RVIM_LSP_ENABLED == '1',
    format_on_save = { enable = true },
    hover_diagnostics = { enable = false, go_to = false, scope = 'cursor' },
    inlay_hint = { enable = false },
    null_ls = { enable = false },
    omnifunc = { enable = true },
    override = {},
    prettier = {
      needs_config = false,
      supported = {
        'css',
        'graphql',
        'handlebars',
        'html',
        'javascript',
        'javascriptreact',
        'json',
        'jsonc',
        'less',
        'markdown',
        'markdown.mdx',
        'scss',
        'typescript',
        'typescriptreact',
        'vue',
        'yaml',
      },
    },
    progress = { enable = true },
    semantic_tokens = { enable = false },
    signs = { enable = false },
    typescript_tools = { enable = true },
    workspace_diagnostics = { enable = false },
  },
  autocommands = { enable = true },
  colors = { enable = true },
  filetypes = { enable = true },
  mappings = { enable = true },
  numbers = { enable = true },
  rooter = { enable = true },
  ui_select = { enable = true },
  none = env.RVIM_NONE == '1',
  noplugin = false,
  plugin = {
    env = { enable = true },
    interceptor = { enable = true },
    last_place = { enable = true },
    large_file = { enable = true },
    notepad = { enable = true },
    remote_sync = { enable = true },
    smart_splits = { enable = true },
    smart_tilde = { enable = true },
    sticky_note = { enable = false },
    tmux = { enable = true },
    whereami = { enable = true },
    whitespace = { enable = true },
  },
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    disabled = {},
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
    modules = {
      disabled = {},
    },
    niceties = env.RVIM_NICETIES_ENABLED == '1',
    overrides = {
      dict = { enable = env.RVIM_DICT_ENABLED == '1' },
      ghost_text = { enable = env.RVIM_GHOST_ENABLED == '1' },
      garbage_day = { enable = false },
    },
  },
  completion = {
    enable = env.RVIM_COMPLETION_ENABLED == '1',
  },
  treesitter = {
    enable = env.RVIM_TREESITTER_ENABLED == '1',
  },
  ui = {
    statuscolumn = { enable = true, custom = true },
    transparent = { enable = true },
    colorscheme = {
      disable = {
        'blue.vim',
        'darkblue.vim',
        'delek.vim',
        'desert.vim',
        'elflord.vim',
        'evening.vim',
        'industry.vim',
        'koehler.vim',
        'lunaperche.vim',
        'morning.vim',
        'murphy.vim',
        'pablo.vim',
        'peachpuff.vim',
        'quiet.vim',
        'retrobox.vim',
        'ron.vim',
        'shine.vim',
        'slate.vim',
        'sorbet.vim',
        'torte.vim',
        'wildcharm.vim',
        'zaibatsu.vim',
        'zellner.vim',
      },
    },
  },
  rtp = {
    disabled = {
      '2html_plugin',
      'bugreport',
      'compiler',
      'getscript',
      'getscriptPlugin',
      'gzip',
      'logipat',
      'matchit',
      'netrw',
      'netrwFileHandlers',
      'netrwPlugin',
      'netrwSettings',
      'optwin',
      -- 'rplugin',
      -- 'rrhelper',
      'spellfile_plugin',
      'synmenu',
      'syntax',
      'tar',
      'tarPlugin',
      'tohtml',
      'tutor',
      'vimball',
      'vimballPlugin',
      'zip',
      'zipPlugin',
    },
  },
}

_G.ar = ar or namespace
_G.map = vim.keymap.set
