if not rvim then return end

local util = require('user.utils.highlights')

local function general_overrides()
  util.all({
    { Normal = { background = { from = 'Normal', alter = -50 } } },
    { NormalFloat = { inherit = 'Normal' } },
    { Dim = { foreground = { from = 'VertSplit', alter = -50 } } },
    { mkdLineBreak = { link = 'NONE' } },
    ------------------------------------------------------------------------------------------------
    { CursorLineSign = { link = 'CursorLine' } },
    { LineNr = { background = 'NONE' } },
    { TermCursor = { ctermfg = 'green', foreground = { from = 'NormalFloat' } } },
    -- Add undercurl to existing spellbad highlight
    { SpellBad = { undercurl = true, background = 'NONE', foreground = 'NONE', sp = 'green' } },
    { SpellRare = { undercurl = true } },
    { CursorLineNr = { background = { from = 'CursorLine' }, bold = true } },
    { SLCopilot = { background = { from = 'StatusLine' } } },
    ------------------------------------------------------------------------------------------------
    -- colorscheme overrides
    ------------------------------------------------------------------------------------------------
    { Include = { italic = true } },
    {
      Folded = {
        background = 'NONE',
        foreground = { from = 'Comment' },
        bold = true,
      },
    },
    { QuickFixLine = { background = { from = 'Search' } } },
    -- Neither the sign column or end of buffer highlights require an explicit background
    -- they should both just use the background that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { background = 'NONE' } },
    { EndOfBuffer = { background = 'NONE' } },
    {
      MatchParen = {
        background = 'NONE',
        foreground = 'NONE',
        bold = false,
        underline = true,
        sp = 'white',
      },
    },
    {
      MatchWord = {
        fg = { from = 'diffRemoved' },
        underline = false,
        cterm = { underline = false },
      },
    },
    { GitSignsCurrentLineBlame = { link = 'Comment' } },
    { Constant = { bold = true } },
    ------------------------------------------------------------------------------------------------
    -- Treesitter
    ------------------------------------------------------------------------------------------------
    { TSNamespace = { foreground = { from = 'TSFunction' }, italic = true, bold = true } },
    { TSKeywordReturn = { italic = true, foreground = { from = 'Keyword' } } },
    { TSConstructor = { foreground = { from = 'TSType' }, italic = true, bold = true } },
    { TSError = { foreground = 'NONE', background = 'NONE' } },
    { TSParameter = { italic = true, bold = true, foreground = 'NONE' } },
    ------------------------------------------------------------------------------------------------
    -- LSP
    ------------------------------------------------------------------------------------------------
    { LspCodeLens = { link = 'NonText' } },
    -- This represents when a reference is assigned which is more interesting than regular
    -- occurrences so should be highlighted more distinctly
    { LspReferenceWrite = { bold = true, italic = true } },
    -- Sign column line
    { DiagnosticSignInfoLine = { inherit = 'DiagnosticVirtualTextInfo', fg = 'NONE' } },
    { DiagnosticSignHintLine = { inherit = 'DiagnosticVirtualTextHint', fg = 'NONE' } },
    { DiagnosticSignErrorLine = { inherit = 'DiagnosticVirtualTextError', fg = 'NONE' } },
    { DiagnosticSignWarnLine = { inherit = 'DiagnosticVirtualTextWarn', fg = 'NONE' } },
  })
end

local function set_sidebar_highlight()
  util.all({
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -43 } } },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { background = { from = 'Normal', alter = -8 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    { PanelVertSplit = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } } },
    {
      PanelVertSplitAlt = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    },
    {
      PanelWinSeparator = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { background = { from = 'Visual', alter = -10 } } },
  })
end

local sidebar_fts = {
  'packer',
  'flutterToolsOutline',
  'undotree',
  'NvimTree',
  'neo-tree',
  'qf',
  'neotest-summary',
}

local function on_sidebar_enter()
  vim.opt_local.winhighlight:append({
    Normal = 'PanelBackground',
    EndOfBuffer = 'PanelBackground',
    StatusLine = 'PanelSt',
    StatusLineNC = 'PanelStNC',
    SignColumn = 'PanelBackground',
    VertSplit = 'PanelVertSplit',
    WinSeparator = 'PanelWinSeparator',
  })
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
end

rvim.augroup('UserHighlights', {
  {
    event = { 'ColorScheme' },
    command = function() user_highlights() end,
  },
  {
    event = { 'FileType' },
    pattern = sidebar_fts,
    command = function() on_sidebar_enter() end,
  },
})

----------------------------------------------------------------------------------------------------
-- Color Scheme {{{1
----------------------------------------------------------------------------------------------------
rvim.wrap_err('theme failed to load because', vim.cmd.colorscheme, 'zephyr')
