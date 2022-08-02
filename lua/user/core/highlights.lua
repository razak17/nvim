if not rvim then return end

local util = require('user.utils.highlights')

local function general_overrides()
  local comment_fg = util.get('Comment', 'fg')
  local search_bg = util.get('Search', 'bg')
  util.all({
    Dim = { foreground = { from = 'Normal', attr = 'bg', alter = 20 } },
    mkdLineBreak = { link = 'NONE' },
    URL = { foreground = { from = 'WinSeparator' }, underline = true },
    ------------------------------------------------------------------------------------------------
    CursorLineSign = { link = 'CursorLine' },
    LineNr = { background = 'NONE' },
    FoldColumn = { background = 'background' },
    TermCursor = { ctermfg = 'green', foreground = { from = 'NormalFloat' } },
    -- Add undercurl to existing spellbad highlight
    SpellBad = { undercurl = true, background = 'NONE', foreground = 'NONE', sp = 'green' },
    SpellRare = { undercurl = true },
    ------------------------------------------------------------------------------------------------
    -- colorscheme overrides
    ------------------------------------------------------------------------------------------------
    Visual = { foreground = { from = 'Search' } },
    Include = { italic = true },
    Folded = {
      background = 'NONE',
      foreground = comment_fg,
      bold = true,
    },
    QuickFixLine = { background = search_bg },
    -- Neither the sign column or end of buffer highlights require an explicit background
    -- they should both just use the background that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    SignColumn = { background = 'NONE' },
    EndOfBuffer = { background = 'NONE' },
    MatchParen = {
      background = 'NONE',
      foreground = 'NONE',
      bold = false,
      underline = true,
      sp = 'white',
    },
    TSNamespace = { foreground = { from = 'TSFunction' }, italic = true, bold = true },
    TSKeywordReturn = { italic = true, foreground = { from = 'Keyword' } },
    TSConstructor = { foreground = { from = 'TSType' }, italic = true, bold = true },
    TSError = { undercurl = true, sp = 'DarkRed', foreground = 'NONE' },
    TSParameter = { italic = true, bold = true, foreground = 'NONE' },
    -- FIXME: this should be removed once
    -- https://github.com/nvim-treesitter/nvim-treesitter/issues/3213 is resolved
    yamlTSError = { link = 'None' },
    LspCodeLens = { link = 'NonText' },
    -- This represents when a reference is assigned which is more interesting than regular
    -- occurrences so should be highlighted more distinctly
    LspReferenceWrite = { bold = true, italic = true },
    MatchWord = { fg = { from = 'diffRemoved' }, underline = false, cterm = { underline = false } },
    GitSignsCurrentLineBlame = { link = 'Comment' },
  })
end

local function set_sidebar_highlight()
  util.all({
    PanelDarkBackground = { bg = { from = 'Normal', alter = -43 } },
    PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true },
    PanelBackground = { background = { from = 'Normal', alter = -8 } },
    PanelHeading = { inherit = 'PanelBackground', bold = true },
    PanelVertSplit = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    PanelVertSplitAlt = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    PanelWinSeparator = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    PanelStNC = { link = 'PanelWinSeparator' },
    PanelSt = { background = { from = 'Visual', alter = -10 } },
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
  vim.wo.winhighlight = table.concat({
    'Normal:PanelBackground',
    'EndOfBuffer:PanelBackground',
    'StatusLine:PanelSt',
    'StatusLineNC:PanelStNC',
    'SignColumn:PanelBackground',
    'VertSplit:PanelVertSplit',
  }, ',')
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
if rvim.plugin_installed('zephyr-nvim') then vim.cmd.colorscheme('zephyr') end
