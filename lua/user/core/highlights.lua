if not rvim.plugin_installed('zephyr-nvim') then return end

local P = require('zephyr.palette')
local util = require('user.utils.highlights')

local function general_overrides()
  local comment_fg = util.get('Comment', 'fg')
  local search_bg = util.get('Search', 'bg')
  util.all({
    Dim = { foreground = { from = 'Normal', attr = 'bg', alter = 50 } },
    mkdLineBreak = { link = 'NONE' },
    URL = { foreground = P.blue, underline = true },
    ------------------------------------------------------------------------------------------------
    CursorLineSign = { link = 'CursorLine' },
    LineNr = { background = 'NONE' },
    FoldColumn = { background = 'background' },
    TermCursor = { ctermfg = 'green', foreground = 'royalblue' },
    -- Add undercurl to existing spellbad highlight
    SpellBad = { undercurl = true, background = 'NONE', foreground = 'NONE', sp = 'green' },
    SpellRare = { undercurl = true },
    ------------------------------------------------------------------------------------------------
    -- colorscheme overrides
    ------------------------------------------------------------------------------------------------
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
    TSNamespace = { foreground = P.pale_pink, italic = true, bold = true },
    TSKeywordReturn = { italic = true, foreground = { from = 'Keyword' } },
    TSConstructor = { foreground = P.teal, italic = true, bold = true },
    TSError = { undercurl = true, sp = 'DarkRed', foreground = 'NONE' },
    TSParameter = { italic = true, bold = true, foreground = 'NONE' },
    -- FIXME: this should be removed once
    -- https://github.com/nvim-treesitter/nvim-treesitter/issues/3213 is resolved
    yamlTSError = { link = 'None' },
    LspCodeLens = { link = 'NonText' },
    LspReferenceText = { underline = true, background = 'NONE', sp = P.comment_grey },
    LspReferenceRead = { underline = true, background = 'NONE', sp = P.comment_grey },
    -- This represents when a reference is assigned which is more interesting than regular
    -- occurrences so should be highlighted more distinctly
    LspReferenceWrite = { underline = true, bold = true, italic = true, background = 'NONE' },
    MatchWord = { fg = P.red, underline = false, cterm = { underline = false } },
    SLCopilot = { fg = P.forest_green, bg = P.dark },
  })
end

local function set_sidebar_highlight()
  local normal_bg = util.get('Normal', 'bg')
  local split_color = util.get('VertSplit', 'fg')
  local dark_bg = util.alter_color(normal_bg, -43)
  local bg_color = util.alter_color(P.bg, -20)
  local st_color = util.alter_color(util.get('Visual', 'bg'), -10)
  util.all({
    PanelDarkBackground = { bg = dark_bg },
    PanelDarkHeading = { bg = dark_bg, bold = true },
    PanelBackground = { link = 'Normal' },
    PanelHeading = { background = bg_color, bold = true },
    PanelVertSplit = { foreground = split_color, background = bg_color },
    PanelVertSplitAlt = { foreground = bg_color, background = bg_color },
    PanelWinSeparator = { foreground = split_color, background = bg_color },
    PanelStNC = { background = st_color, cterm = { italic = true } },
    PanelSt = { background = st_color },
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
vim.g.colors_name = rvim.colorscheme
vim.cmd('colorscheme ' .. rvim.colorscheme)
