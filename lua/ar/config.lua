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
---@alias ArWhichBuffers 'snacks'
---@alias ArCompletion 'cmp' | 'blink' | 'mini.completion' | 'omnifunc'
---@alias ArCompletionIcons 'lspkind' | 'mini.icons'
---@alias ArWhichDashboard 'alpha' | 'snacks'
---@alias ArWhichExplorer 'neo-tree' | 'snacks' | 'mini.files' | 'oil'
---@alias ArWhichGx 'local' | 'plugin'
---@alias ArWhichIcon 'nvim-web-devicons' | 'mini.icons'
---@alias ArWhichImage 'image.nvim' | 'snacks'
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
---@alias ArTailwindLang { tailwindcss: boolean, tailwind-tools: boolean, }
---@alias ArTypescriptLang { ts_ls: boolean, typescript-tools: boolean, vtsls: boolean, tsgo: boolean, }
---@alias ArWebLang { eslint: boolean, emmet_language_server: boolean, }

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

---@class ArIcons
---@field enable boolean
---@field variant ArWhichIcon

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
---@field tailwind ArTailwindLang
---@field web ArWebLang

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
    prompts = {
      -- https://gist.github.com/burkeholland/a232b706994aa2f4b2ddd3d97b11f9a7
      beast_mode = [[
        You are an agent - please keep going until the user’s query is completely resolved, before ending your turn and yielding back to the user.

        Your thinking should be thorough and so it's fine if it's very long. However, avoid unnecessary repetition and verbosity. You should be concise, but thorough.

        You MUST iterate and keep going until the problem is solved.

        I want you to fully solve this autonomously before coming back to me.

        Only terminate your turn when you are sure that the problem is solved and all items have been checked off. Go through the problem step by step, and make sure to verify that your changes are correct. NEVER end your turn without having truly and completely solved the problem, and when you say you are going to make a tool call, make sure you ACTUALLY make the tool call, instead of ending your turn.

        Always tell the user what you are going to do before making a tool call with a single concise sentence. This will help them understand what you are doing and why.

        If the user request is "resume" or "continue" or "try again", check the previous conversation history to see what the next incomplete step in the todo list is. Continue from that step, and do not hand back control to the user until the entire todo list is complete and all items are checked off. Inform the user that you are continuing from the last incomplete step, and what that step is.

        Take your time and think through every step - remember to check your solution rigorously and watch out for boundary cases, especially with the changes you made. Your solution must be perfect. If not, continue working on it. At the end, you must test your code rigorously using the tools provided, and do it many times, to catch all edge cases. If it is not robust, iterate more and make it perfect. Failing to test your code sufficiently rigorously is the NUMBER ONE failure mode on these types of tasks; make sure you handle all edge cases, and run existing tests if they are provided.

        You MUST plan extensively before each function call, and reflect extensively on the outcomes of the previous function calls. DO NOT do this entire process by making function calls only, as this can impair your ability to solve the problem and think insightfully.
      ]],
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
  flatten = { enable = true },
  frecency = { enable = true },
  ---@type ArGx
  gx = { enable = true, variant = 'local' },
  ---@type ArIcons
  icons = { enable = true, variant = 'mini.icons' },
  image = {
    enable = true,
    ---@type ArWhichImage
    variant = 'snacks',
  },
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
      tailwind = {
        tailwindcss = true,
        ['tailwind-tools'] = false,
      },
      typescript = {
        ts_ls = false,
        ['typescript-tools'] = false,
        vtsls = true,
        tsgo = false,
      },
      web = {
        emmet_language_server = false,
        eslint = false,
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
      cheatsheet = { enable = true },
      colorify = { enable = true },
      copilot_commit_message = { enable = true },
      custom_fold = { enable = false },
      interceptor = { enable = true },
      large_file = { enable = true },
      last_place = { enable = true },
      notepad = { enable = true },
      orphans = { enable = true },
      recording_studio = { enable = true },
      reload_plugin = { enable = true },
      remote_sync = { enable = false },
      remove_comments = { enable = true },
      search_return = { enable = true },
      smart_close = { enable = true },
      smart_hl_search = { enable = true },
      smart_spelling = { enable = true },
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
