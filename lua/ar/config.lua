--------------------------------------------------------------------------------
-- Global namespace
--------------------------------------------------------------------------------
local env = vim.env

---@alias ArCond {enable: boolean,}

---@class ArApps
---@field image string
---@field pdf string
---@field audio string
---@field video string
---@field web string
---@field explorer string

---@alias ArGxMode 'local' | 'plugin'

---@class ArMedia
---@field audio table
---@field doc table
---@field image table
---@field video table

---@class ArLspDisabled
---@field filetypes table
---@field directories table
---@field servers table

---@alias ArLspProgress 'noice' | 'builtin'

---@alias ArTypescriptLsp 'ts_ls' | 'typescript-tools' | 'vtsls'

---@class ArLsp
---@field disabled ArLspDisabled
---@field enable boolean
---@field format_on_save ArCond
---@field hover_diagnostics table
---@field inlay_hint ArCond
---@field null_ls ArCond
---@field omnifunc ArCond
---@field override table
---@field prettier table
---@field progress ArLspProgress
---@field semantic_tokens ArCond
---@field signs ArCond
---@field typescript_lsp ArTypescriptLsp
---@field workspace_diagnostics ArCond

---@class ArPlugin
---@field env ArCond
---@field interceptor ArCond
---@field last_place ArCond
---@field large_file ArCond
---@field notepad ArCond
---@field remote_sync ArCond
---@field smart_splits ArCond
---@field smart_tilde ArCond
---@field sticky_note ArCond
---@field tmux ArCond
---@field whereami ArCond
---@field whitespace ArCond

---@class ArPluginsOverride
---@field dict ArCond
---@field ghost_text ArCond
---@field garbage_day ArCond

---@class ArPlugins
---@field enable boolean
---@field disabled table
---@field minimal boolean
---@field modules table
---@field niceties boolean
---@field overrides ArPluginsOverride

---@class ArUIColorscheme
---@field disabled table

---@class ArUI
---@field statuscolumn ArCond
---@field transparent ArCond
---@field colorscheme ArUIColorscheme

---@class ArRTP
---@field disabled table

---@class ArConfig
---@field ai table
---@field animation table
---@field apps ArApps
---@field autosave table
---@field colorscheme string
---@field debug table
---@field frecency table
---@field git table
---@field gx ArGxMode
---@field media ArMedia
---@field lsp ArLsp
---@field autocommands ArCond
---@field colors ArCond
---@field filetypes ArCond
---@field mappings ArCond
---@field numbers ArCond
---@field rooter ArCond
---@field ui_select ArCond
---@field none boolean
---@field noplugin boolean
---@field plugin ArPlugin
---@field plugins ArPlugins
---@field completion table
---@field treesitter table
---@field ui ArUI
---@field rtp ArRTP

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  animation = { enable = false },
  ---@type ArApps
  apps = {
    image = 'sxiv',
    pdf = 'zathura',
    audio = 'mpv',
    video = 'mpv',
    web = 'firefox',
    explorer = 'thunar',
  },
  autosave = {
    enable = true,
    current = true,
  },
  colorscheme = 'onedark',
  debug = { enable = false },
  frecency = { enable = true },
  git = {},
  ---@type ArGxMode
  gx = 'plugin',
  ---@type ArMedia
  media = {
    audio = { 'mp3', 'm4a' },
    doc = { 'pdf' },
    image = { 'jpg', 'png', 'jpeg', 'ico', 'gif' },
    video = { 'mp4', 'mkv' },
  },
  ---@type ArLsp
  lsp = {
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'denols', 'emmet_ls' },
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
    progress = 'noice',
    semantic_tokens = { enable = false },
    signs = { enable = false },
    typescript_lsp = 'typescript-tools',
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
  ---@type ArPlugin
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
  ---@type ArPlugins
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
  ---@type ArUI
  ui = {
    statuscolumn = { enable = true, custom = true },
    transparent = { enable = true },
    colorscheme = {
      disabled = {
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
  ---@type ArRTP
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
