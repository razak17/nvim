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
---@alias ArAICompletion 'builtin' | 'copilot' | 'minuet'
---@alias ArAISuggestions 'ghost-text' | 'completion'
---@alias ArAIWhichOpencode 'tui' | 'frontend'
---@alias ArExplorerRename 'local' | 'snacks'
---@alias ArWhichBorder 'single' | 'rounded' | 'none' | 'double' | 'solid' | 'shadow'
---@alias ArWhichBuffers 'snacks' | 'fzf-lua'
---@alias ArWhichCmdline 'builtin' | 'extui' | 'noice' | 'telescope-cmdline'
---@alias ArCompletion 'cmp' | 'blink' | 'mini.completion' | 'omnifunc'
---@alias ArCompletionIcons 'lspkind' | 'mini.icons'
---@alias ArWhichDashboard 'builtin' | 'alpha' | 'snacks'
---@alias ArWhichExplorer 'neo-tree' | 'snacks' | 'mini.files' | 'oil' | 'fyler'
---@alias ArWhichGx 'local' | 'plugin'
---@alias ArWhichIcon 'nvim-web-devicons' | 'mini.icons'
---@alias ArWhichImage 'image.nvim' | 'snacks'
---@alias ArWhichIndentline 'mini.indentscope' | 'ibl' | 'snacks' | 'indentmini'
---@alias ArWhichLspCodeAction 'builtin' | 'tiny-code-action'
---@alias ArWhichLspProgress 'builtin' | 'noice'
---@alias ArWhichLspProgressSpinner 'dots' | 'circle'
---@alias ArWhichLspRename 'builtin' | 'inc-rename'
---@alias ArWhichLspSymbols 'builtin' | 'picker' | 'namu'
---@alias ArWhichLspVirtualLines 'builtin' | 'lsp_lines' | 'tiny-inline'
---@alias ArWhichLspVirtualText 'builtin' | 'lsp_lines' | 'tiny-inline'
---@alias ArWhichNotifier 'native' | 'nvim-notify' | 'snacks' | 'noice'
---@alias ArWhichPicker 'snacks' | 'telescope' | 'fzf-lua' | 'mini.pick'
---@alias ArWhichSession 'persisted' | 'persistence'
---@alias ArWhichFilesPicker 'smart-open' | 'snacks' | 'telescope' | 'fzf-lua' | 'mini.pick' | 'fff'
---@alias ArWhichScroll 'snacks' | 'neoscroll'
---@alias ArWhichShelter 'cloak' | 'ecolog'
---@alias ArWhichStatuscolumn 'local' | 'heirline'
---@alias ArWhichStatusline 'local' | 'heirline'
---@alias ArWhichWinbar 'local' | 'dropbar'

---@alias ArCond {enable: boolean,}
---@alias ArPythonLang { basedpyright: boolean, ruff: boolean, ty: boolean, jedi_language_server: boolean, pyrefly: boolean, }
---@alias ArRustLang { rustaceanvim: boolean, rust_analyzer: boolean, bacon_ls: boolean}
---@alias ArTailwindLang { tailwindcss: boolean, tailwind-tools: boolean, }
---@alias ArTypescriptLang { ts_ls: boolean, typescript-tools: boolean, vtsls: boolean, tsgo: boolean, }
---@alias ArWebLang { biome: boolean,  eslint: boolean, emmet_language_server: boolean, }
---@alias ArPickerWin { show_preview: boolean, fullscreen: boolean, }

---@class ArAIModels
---@field claude boolean
---@field gemini boolean
---@field openai boolean
---@field copilot boolean

---@class ArBuffers
---@field enable boolean
---@field variant ArWhichBuffers

---@class ArCmdline
---@field enable boolean
---@field variant ArWhichCmdline

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
---@field win ArPickerWin

---@class ArSession
---@field enable boolean
---@field variant ArWhichSession

---@class ArLspLang
---@field python ArPythonLang
---@field rust ArRustLang
---@field typescript ArTypescriptLang
---@field tailwind ArTailwindLang
---@field web ArWebLang

---@class ArLspProgress
---@field enable boolean
---@field variant ArWhichLspProgress
---@field spinner ArWhichLspProgressSpinner

---@class ArIndentline
---@field enable boolean
---@field variant ArWhichIndentline

---@class ArScroll
---@field enable boolean
---@field variant ArWhichScroll

---@class ArStatuscolumn
---@field enable boolean
---@field variant ArWhichStatuscolumn

---@class ArStatusline
---@field enable boolean
---@field variant ArWhichStatusline

---@class ArWinbar
---@field enable boolean
---@field variant ArWhichWinbar

---@class ArLspCodeAction
---@field enable boolean
---@field variant ArWhichLspCodeAction

---@class ArLspRename
---@field enable boolean
---@field variant ArWhichLspRename

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
---@field rename ArLspRename
---@field signs ArCond
---@field code_actions ArLspCodeAction
---@field symbols ArLspSymbols
---@field virtual_lines ArLspVirtualLines
---@field virtual_text ArLspVirtualText

---@class ArPluginItem
---@field enable boolean
---@field config? table

---@class ArPluginsOverride
---@field dict ArCond
---@field ghost_text ArCond

---@class ArPlugins
---@field enable boolean
---@field coding boolean
---@field disabled table
---@field minimal boolean
---@field modules table
---@field niceties boolean
---@field overrides ArPluginsOverride
---@field profile boolean

---@class ArUIColorscheme
---@field disabled table

---@class ArUI
---@field decorations table
---@field statuscolumn ArCond
---@field transparent ArCond
---@field colorscheme ArUIColorscheme

local namespace = {
  ai = {
    enable = env.RVIM_AI_ENABLED == '1',
    copilot_models = {
      ['claude-sonnet-4'] = {},
      ['claude-sonnet-4.5'] = {},
      ['claude-haiku-4.5'] = {},
      ['claude-opus-4.5'] = {},
      ['gemini-2.5-pro'] = {},
      ['gemini-3-pro'] = {},
      ['gemini-3-flash'] = {},
      ['grok-code-fast-1'] = {},
      ['gpt-4'] = { max_tokens = 32768 },
      ['gpt-4.1'] = {},
      ['gpt-4o-2024-11-20'] = { max_tokens = 64000 },
      ['gpt-4o-mini'] = { max_tokens = 12288 },
      ['gpt-5'] = {},
      ['gpt-5-mini'] = {},
      ['gpt-5.1'] = {},
      ['gpt-5.2'] = {},
      ['oswe-vscode-prime'] = {},
    },
    openai_models = {
      ['gpt-5.2'] = {},
      ['gpt-5.1'] = {},
      ['gpt-5'] = {},
      ['gpt-5-mini'] = {},
      ['gpt-5-nano'] = { temp = 1 },
      ['gpt-4o'] = {},
      ['gpt-4o-mini'] = {},
      ['o4-mini'] = {},
      ['o3-mini'] = {},
      ['gpt-4'] = {},
      ['gpt-4.1'] = {},
    },
  },
  ---@type ArMedia
  media = {
    audio = { 'mp3', 'm4a' },
    doc = { 'pdf' },
    image = { 'jpg', 'png', 'jpeg', 'ico', 'avif', 'webp', 'gif' },
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
    coding = env.RVIM_PLUGINS_CODING == '1',
    minimal = env.RVIM_PLUGINS_MINIMAL == '1',
    niceties = env.RVIM_NICETIES_ENABLED == '1',
    overrides = {
      dict = { enable = env.RVIM_DICT_ENABLED == '1' },
    },
    profile = env.RVIM_PROFILE == '1',
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
        'quiet.vim',
        'ron.vim',
        'shine.vim',
        'sorbet.vim',
        'torte.vim',
        'unokai.vim',
        'zaibatsu.vim',
        'zellner.vim',
      },
      list = {},
    },
  },
}

local config = {
  ai = {
    ---@type ArAIModels
    models = {
      claude = false,
      copilot = true,
      gemini = true,
      openai = true,
    },
    completion = {
      enable = false,
      ---@type ArAICompletion
      variant = 'builtin',
      ---@type ArAISuggestions
      suggestions = 'ghost-text',
    },
    opencode = {
      enable = true,
      ---@type ArAIWhichOpencode
      variant = 'tui',
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
    snippets = {
      enable = true,
      ---@type 'minimal' | 'friendly-snippets'
      variant = 'minimal',
    },
  },
  colorscheme = {
    use_in_minimal_mode = false,
    name = '',
    ---@type 'fill' | 'outline'
    variant = 'outline',
  },
  ---@type ArDashboard
  dashboard = { enable = true, variant = 'builtin' },
  debug = { enable = false },
  ---@type ArExplorer
  explorer = { rename = 'snacks', variant = 'snacks' },
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
      servers = {},
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
        jedi_language_server = false,
        pyrefly = false,
      },
      rust = {
        bacon_ls = false,
        rustaceanvim = true,
        rust_analyzer = false,
      },
      tailwind = {
        tailwindcss = false,
        ['tailwind-tools'] = false,
      },
      typescript = {
        ts_ls = false,
        ['typescript-tools'] = false,
        vtsls = true,
        tsgo = false,
        denols = false,
      },
      web = {
        biome = false,
        emmet_language_server = false,
        emmet_ls = false,
        eslint = false,
      },
    },
    null_ls = { enable = false },
    omnifunc = { enable = true },
    override = {},
    progress = { enable = true, variant = 'builtin', spinner = 'circle' },
    rename = { enable = true, variant = 'inc-rename' },
    signs = { enable = false },
    symbols = { enable = true, variant = 'namu' },
    code_actions = { enable = true, variant = 'builtin' },
    virtual_text = { enable = false },
    virtual_lines = { enable = false, variant = 'tiny-inline' },
  },
  ---@type ArNotifier
  notifier = { enable = true, variant = 'snacks' },
  ---@type ArPicker
  picker = {
    enable = true,
    files = 'snacks',
    variant = 'snacks',
    win = { show_preview = false, fullscreen = true },
  },
  plugin = {
    custom = {
      accelerated_jk = { enable = true },
      advanced_new_file = { enable = true },
      auto_cursorline = { enable = true },
      baredot = { enable = true },
      big_file = { enable = true },
      cheatsheet = { enable = true },
      colorify = { enable = true },
      comment = { enable = true },
      copilot_commit_message = { enable = true },
      custom_fold = { enable = false },
      dump_messages = { enable = true },
      git_conflict = { enable = false },
      interceptor = { enable = true },
      large_file = { enable = true },
      last_place = { enable = true },
      modify_line_end_delimiter = { enable = true },
      notepad = { enable = true },
      null_pointer = { enable = true },
      orphans = { enable = true },
      recording_studio = { enable = true },
      reload_plugin = { enable = true },
      remote_sync = { enable = false },
      remove_comments = { enable = true },
      replace_word = { enable = true },
      search_return = { enable = true },
      smart_close = { enable = true },
      smart_hl_search = { enable = true },
      smart_spelling = { enable = true },
      smart_splits = { enable = true },
      smart_tilde = { enable = true },
      spell_all_good = { enable = true },
      sticky_note = { enable = false },
      sticky_yank = { enable = true },
      surf_plugins = { enable = true },
      tab_search = { enable = true },
      wb_current_line = { enable = true },
      word_web_search = { enable = true },
      yank_ring = { enable = true },
    },
    main = {
      autocommands = { enable = true },
      colors = { enable = true },
      env = { enable = true },
      experimental = { enable = true },
      filetypes = { enable = true },
      mappings = { enable = true },
      numbers = { enable = true },
      pack = { enable = true },
      rooter = { enable = true },
      select_menu = { enable = true },
      tmux = { enable = true },
      whitespace = { enable = true },
    },
  },
  plugins = {
    override = {},
    disabled = {
      'VectorCode',
      'agentic.nvim',
      'btw.nvim',
      'cmp-path',
      'conflict.nvim',
      'dev-tools.nvim',
      'flatten.nvim',
      'fold-imports.nvim',
      'garbage-day.nvim',
      'git-conflict.nvim',
      'hlchunk.nvim',
      'incline.nvim',
      'inlayhint-filler.nvim',
      'lsplinks.nvim',
      'neoconf.nvim',
      'nvim-toggler',
      'nvim-ufo',
      'pair-lens.nvim',
      'persistent-breakpoints.nvim',
      'readline.nvim',
      'rest.nvim',
      'sidekick.nvim',
      'startup.nvim',
      'suda.vim',
      'telescope-smart-history.nvim',
      'ts-comments.nvim',
      'ultimate-autopair.nvim',
      'vim-footprints',
      'vim-matchup',
    },
    modules = {
      disabled = {},
      override = {},
    },
  },
  ---@type ArSession
  session = { enable = true, variant = 'persisted' },
  shelter = {
    enable = true,
    ---@type ArWhichShelter
    variant = 'cloak',
  },
  ui = {
    ---@type ArWhichBorder
    border = 'single',
    ---@type ArCmdline
    cmdline = { enable = true, variant = 'builtin' },
    ---@type ArIndentline
    indentline = { enable = true, variant = 'snacks' },
    ---@type ArScroll
    scroll = { enable = true, variant = 'snacks' },
    ---@type ArStatuscolumn
    statuscolumn = { enable = true, variant = 'local' },
    ---@type ArStatusline
    statusline = { enable = true, variant = 'heirline' },
    ---@type ArWinbar
    winbar = { enable = true, variant = 'dropbar' },
    transparent = { enable = true },
  },
}

_G.ar = ar or namespace
_G.ar.config = config
_G.ar.pick = require('ar.pick')
_G.map = vim.keymap.set
