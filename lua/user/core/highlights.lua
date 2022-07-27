local P = require('zephyr.palette')
local util = require('zephyr.utils')

local function general_overrides()
  local comment_fg = util.get('Comment', 'fg')
  local keyword_fg = util.get('Keyword', 'fg')
  local search_bg = util.get('Search', 'bg')
  -- local error_line = util.alter_color(P.error_red, -80)
  local msg_area_bg = rvim.ui.transparent_window and 'NONE' or P.darker_bg
  util.all({
    MsgArea = { background = msg_area_bg },
    mkdLineBreak = { link = 'NONE' },
    -- Directory = { inherit = "Keyword", bold = true },
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
    -- Comment = { italic = true } ,
    Include = { italic = true },
    -- Type = { italic = true, bold = true } ,
    Folded = {
      background = 'NONE',
      foreground = comment_fg,
      bold = true,
      -- italic = true,
    },
    QuickFixLine = { background = search_bg },
    Visual = {
      foreground = 'NONE',
      background = util.alter_color(P.pale_blue, -50),
    },
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
    ------------------------------------------------------------------------------------------------
    -- Treesitter
    ------------------------------------------------------------------------------------------------
    TSNamespace = { foreground = P.pale_pink, italic = true, bold = true },
    TSKeywordReturn = { italic = true, foreground = keyword_fg },
    TSConstructor = { foreground = P.teal, italic = true, bold = true },
    -- TSError = { undercurl = true, sp = error_line, foreground = "NONE" } ,
    TSParameter = { italic = true, bold = true, foreground = 'NONE' },
    -- highlight FIXME comments
    commentTSWarning = { background = P.teal, foreground = P.base0, bold = true },
    commentTSDanger = { background = P.dark_green, foreground = P.base0, bold = true },
    commentTSNote = { background = P.blue, foreground = P.base0, bold = true },
    CommentTasksTodo = { link = 'commentTSWarning' },
    CommentTasksFixme = { link = 'commentTSDanger' },
    CommentTasksNote = { link = 'commentTSNote' },
    ------------------------------------------------------------------------------------------------
    -- LSP
    ------------------------------------------------------------------------------------------------
    LspCodeLens = { link = 'NonText' },
    LspReferenceText = { underline = true, background = 'NONE' },
    LspReferenceRead = { underline = true, background = 'NONE' },
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
