--------------------------------------------------------------------------------
-- Global namespace
--------------------------------------------------------------------------------
local env = vim.env

---@class ArApps
---@field image string
---@field pdf string
---@field audio string
---@field video string
---@field web string
---@field explorer string

---@class ArMedia
---@field audio table
---@field doc table
---@field image table
---@field video table

---@class ArLspDisabled
---@field filetypes table
---@field directories table
---@field servers table

---@alias ArAIModel 'claude' | 'gemini' | 'openai' | 'copilot'
---@alias ArAICompletion 'copilot' | 'minuet'
---@alias ArExplorerRename 'local' | 'snacks'
---@alias ArWhichBuffers 'bufexplorer' | 'bufferin' | 'snacks'
---@alias ArCompletion 'cmp' | 'blink' | 'mini.completion' | 'omnifunc'
---@alias ArCompletionIcons 'lspkind' | 'mini.icons'
---@alias ArWhichDashboard 'alpha' | 'snacks'
---@alias ArWhichExplorer 'neo-tree' | 'snacks' | 'mini.files' | 'oil'
---@alias ArWhichGx 'local' | 'plugin'
---@alias ArWhichIndentline 'mini.indentscope' | 'ibl' | 'snacks' | 'indentmini'
---@alias ArWhichLspProgress 'builtin' | 'noice' | 'snacks'
---@alias ArWhichLspSymbols 'builtin' | 'picker' | 'namu'
---@alias ArWhichLspVirtualLines 'builtin' | 'lsp_lines' | 'tiny-inline'
---@alias ArWhichLspVirtualText 'builtin' | 'lsp_lines' | 'tiny-inline'
---@alias ArWhichNotifier 'nvim-notify' | 'snacks'
---@alias ArWhichPicker 'snacks' | 'telescope' | 'fzf-lua' | 'mini.pick'
---@alias ArWhichSession 'persisted' | 'persistence'
---@alias ArWhichFilesPicker 'smart-open' | 'snacks' | 'telescope' | 'fzf-lua' | 'mini.pick'
---@alias ArWhichShelter 'cloak' | 'ecolog'
---@alias ArWhichStatuscolumn 'local' | 'plugin'
---@alias ArWhichWinbar 'local' | 'plugin'

---@alias ArCond {enable: boolean,}
---@alias ArPythonLang { basedpyright: boolean, ruff: boolean, ty: boolean, }
---@alias ArTypescriptLang { ts_ls: boolean, typescript-tools: boolean, vtsls: boolean, tsgo: boolean, }

---@class ArAIModels
---@field claude boolean
---@field gemini boolean
---@field openai boolean
---@field copilot boolean

---@class ArBuffers
---@field enable boolean
---@field variant ArWhichBuffers

---@class ArDashboard
---@field enable boolean
---@field variant ArWhichDashboard

---@class ArExplorer
---@field rename ArExplorerRename
---@field variant ArWhichExplorer

---@class ArGx
---@field enable boolean
---@field variant ArWhichGx

---@class ArNotifier
---@field enable boolean
---@field variant ArWhichNotifier

---@class ArPicker
---@field enable boolean
---@field files ArWhichFilesPicker
---@field variant ArWhichPicker

---@class ArSession
---@field enable boolean
---@field variant ArWhichSession

---@class ArLspLang
---@field python ArPythonLang
---@field typescript ArTypescriptLang

---@class ArLspProgress
---@field enable boolean
---@field variant ArWhichLspProgress

---@class ArIndentline
---@field enable boolean
---@field variant ArWhichIndentline

---@class ArStatuscolumn
---@field enable boolean
---@field variant ArWhichStatuscolumn

---@class ArWinbar
---@field enable boolean
---@field variant ArWhichWinbar

---@class ArLspSymbols
---@field enable boolean
---@field variant ArWhichLspSymbols

---@class ArLspVirtualLines
---@field enable boolean
---@field variant ArWhichLspVirtualLines

---@class ArLspVirtualText
---@field enable boolean
---@field variant ArWhichLspVirtualText

---@class ArLsp
---@field disabled ArLspDisabled
---@field foldexpr ArCond
---@field format_on_save ArCond
---@field hover_diagnostics table
---@field inlay_hint ArCond
---@field lang ArLspLang
---@field null_ls ArCond
---@field omnifunc ArCond
---@field override table
---@field progress ArLspProgress
---@field semantic_tokens ArCond
---@field signs ArCond
---@field symbols ArLspSymbols
---@field virtual_lines ArLspVirtualLines
---@field virtual_text ArLspVirtualText
---@field workspace_diagnostics ArCond

---@class ArPluginItem
---@field enable boolean
---@field config? table

---@class ArPluginsOverride
---@field dict ArCond
---@field ghost_text ArCond

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
---@field decorations table
---@field statuscolumn ArCond
---@field transparent ArCond
---@field colorscheme ArUIColorscheme

---@class ArRTP
---@field disabled table

local namespace = {
  ai = { enable = env.RVIM_AI_ENABLED == '1' },
  ---@type ArMedia
  media = {
    audio = { 'mp3', 'm4a' },
    doc = { 'pdf' },
    image = { 'jpg', 'png', 'jpeg', 'ico', 'gif' },
    video = { 'mp4', 'mkv' },
  },
  git = { enable = env.RVIM_GIT_ENABLED == '1' },
  kitty_scrollback = { enable = env.KITTY_SCROLLBACK_NVIM == 'true' },
  lsp = {
    -- codes: https://github.com/microsoft/TypeScript/blob/main/src/compiler/diagnosticMessages.json
    disabled_codes = {
      ts = {
        80001, -- Ignore this might be converted to a ES export
        80006, -- Ignore this might be converted into an async function
        -- 6133, -- Ignore this var declared but its value is never read
      },
    },
    enable = env.RVIM_LSP_ENABLED == '1',
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
  },
  select_menu = {
    ai = { title = 'A.I. actions', options = {} },
    command_palette = { title = 'Command Palette actions', options = {} },
    git = { title = 'Git commands', options = {} },
    lsp = { title = 'Code/LSP actions', options = {} },
    toggle = { title = 'Toggle actions', options = {} },
    w3m = { title = 'W3M actions', options = {} },
  },
  none = env.RVIM_NONE == '1',
  ---@type ArPlugins
  plugins = {
    enable = env.RVIM_PLUGINS_ENABLED == '1',
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
    niceties = env.RVIM_NICETIES_ENABLED == '1',
    overrides = {
      dict = { enable = env.RVIM_DICT_ENABLED == '1' },
      ghost_text = { enable = env.RVIM_GHOST_ENABLED == '1' },
    },
  },
  completion = { enable = env.RVIM_COMPLETION_ENABLED == '1' },
  treesitter = {
    enable = env.RVIM_TREESITTER_ENABLED == '1',
    extra = { enable = env.RVIM_TREESITTER_EXTRA_ENABLED == '1' },
  },
  ui = {
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
        'unokai.vim',
        'vim.vim',
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

local config = {
  ai = {
    ---@type ArAIModels
    models = {
      claude = false,
      copilot = true,
      gemini = true,
      openai = false,
    },
    completion = {
      enable = false,
      ---@type ArAICompletion
      variant = 'copilot',
    },
    ignored_filetypes = {
      'DressingInput',
      'NeogitCommitMessage',
      'TelescopePrompt',
      'TelescopePrompt',
      'dap-repl',
      'fzf',
      'gitcommit',
      'markdown',
      'minifiles',
      'neo-tree-popup',
      'noice',
      'snacks_picker_input',
    },
  },
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
  autosave = { enable = true, current = true },
  ---@type ArBuffers
  buffers = { enable = true, variant = 'snacks' },
  completion = {
    ---@type ArCompletionIcons
    icons = 'lspkind',
    ---@type ArCompletion
    variant = 'blink',
  },
  colorscheme = ar.plugins.minimal and 'default' or 'onedark',
  ---@type ArDashboard
  dashboard = { enable = true, variant = 'alpha' },
  debug = { enable = false },
  ---@type ArExplorer
  explorer = { rename = 'snacks', variant = 'snacks' },
  frecency = { enable = true },
  ---@type ArGx
  gx = { enable = true, variant = 'plugin' },
  ---@type ArLsp
  lsp = {
    disabled = {
      filetypes = {},
      directories = { vim.fn.stdpath('data') },
      servers = { 'emmet_ls', 'pyright', 'jedi_language_server' },
    },
    foldexpr = { enable = false },
    format_on_save = { enable = true },
    hover_diagnostics = { enable = false, go_to = false, scope = 'cursor' },
    inlay_hint = { enable = false },
    lang = {
      python = {
        pyright = false,
        ruff = true,
        basedpyright = true,
        ty = false,
      },
      typescript = {
        ts_ls = false,
        ['typescript-tools'] = false,
        vtsls = false,
        tsgo = true,
      },
    },
    null_ls = { enable = false },
    omnifunc = { enable = true },
    override = {},
    progress = { enable = true, variant = 'noice' },
    semantic_tokens = { enable = false },
    signs = { enable = false },
    symbols = { enable = true, variant = 'namu' },
    virtual_text = { enable = false },
    virtual_lines = { enable = false, variant = 'tiny-inline' },
    workspace_diagnostics = { enable = false },
  },
  ---@type ArNotifier
  notifier = { enable = true, variant = 'snacks' },
  ---@type ArPicker
  picker = { enable = true, files = 'snacks', variant = 'snacks' },
  plugin = {
    custom = {
      accelerated_jk = { enable = true },
      auto_cursorline = { enable = true },
      baredot = { enable = true },
      big_file = { enable = true },
      colorify = { enable = true },
      custom_fold = { enable = false },
      interceptor = { enable = true },
      large_file = { enable = true },
      last_place = { enable = true },
      notepad = { enable = true },
      recording_studio = { enable = true },
      reload_plugin = { enable = true },
      remote_sync = { enable = false },
      remove_comments = { enable = true },
      search_return = { enable = true },
      smart_close = { enable = true },
      smart_hl_search = { enable = true },
      smart_splits = { enable = true },
      smart_tilde = { enable = true },
      sticky_note = { enable = false },
      sticky_yank = { enable = true },
      surf_plugins = { enable = true },
      wb_current_line = { enable = true },
      yank_ring = { enable = true },
    },
    main = {
      autocommands = { enable = true },
      colors = { enable = true },
      env = { enable = true },
      filetypes = { enable = true },
      mappings = { enable = true },
      numbers = { enable = true },
      rooter = { enable = true },
      select_menu = { enable = true },
      tmux = { enable = true },
      whitespace = { enable = true },
    },
  },
  plugins = {
    disabled = {},
    modules = {
      disabled = {},
    },
    overrides = {
      garbage_day = { enable = false },
    },
  },
  ---@type ArSession
  session = { enable = true, variant = 'persisted' },
  shelter = {
    enable = true,
    ---@type ArWhichShelter
    variant = 'ecolog',
  },
  ui = {
    ---@type ArIndentline
    indentline = { enable = true, variant = 'snacks' },
    ---@type ArStatuscolumn
    statuscolumn = { enable = true, variant = 'local' },
    ---@type ArWinbar
    winbar = { enable = true, variant = 'plugin' },
    transparent = { enable = true },
  },
}
_G.ar_config = config

_G.map = vim.keymap.set
_G.ar.pick = require('ar.pick')
