local P = rvim.palette
local util = require("user.utils.highlights")

local function general_overrides()
  local comment_fg = util.get("Comment", "fg")
  local keyword_fg = util.get("Keyword", "fg")
  local search_bg = util.get("Search", "bg")
  -- local error_line = util.alter_color(P.error_red, -80)
  local msg_area_bg = rvim.util.transparent_window and "NONE" or P.darker_bg
  util.all({
    -- WinSeparator = { background = "NONE", foreground = util.get("VertSplit", "fg") },
    MsgArea = { background = msg_area_bg },
    mkdLineBreak = { link = "NONE" },
    -- Directory = { inherit = "Keyword", bold = true },
    URL = { foreground = P.darker_blue, underline = true },
    -----------------------------------------------------------------------------//
    CursorLineNr = { foreground = { from = "Keyword" } },
    LineNr = { background = "NONE" },
    FoldColumn = { background = "background" },
    TermCursor = { ctermfg = "green", foreground = "royalblue" },
    -- Add undercurl to existing spellbad highlight
    SpellBad = { undercurl = true, background = "NONE", foreground = "NONE", sp = "green" },
    SpellRare = { undercurl = true },
    -----------------------------------------------------------------------------//
    -- colorscheme overrides
    -----------------------------------------------------------------------------//
    -- Comment = { italic = true } ,
    Include = { italic = true },
    -- Type = { italic = true, bold = true } ,
    Folded = {
      background = "NONE",
      foreground = comment_fg,
      bold = true,
      -- italic = true,
    },
    QuickFixLine = { background = search_bg },
    Visual = {
      foreground = "NONE",
      background = util.alter_color(P.pale_blue, -50),
    },
    -- Neither the sign column or end of buffer highlights require an explicit background
    -- they should both just use the background that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    SignColumn = { background = "NONE" },
    EndOfBuffer = { background = "NONE" },
    MatchParen = {
      background = "NONE",
      foreground = "NONE",
      bold = false,
      underlineline = true,
      sp = "white",
    },
    -----------------------------------------------------------------------------//
    -- Treesitter
    -----------------------------------------------------------------------------//
    TSNamespace = { foreground = P.pale_pink, italic = true, bold = true },
    TSKeywordReturn = { italic = true, foreground = keyword_fg },
    -- TSError = { undercurl = true, sp = error_line, foreground = "NONE" } ,
    TSParameter = { italic = true, bold = true, foreground = "NONE" },
    -- highlight FIXME comments
    commentTSWarning = { background = P.error_red, foreground = "fg", bold = true },
    commentTSDanger = { background = P.dark_green, foreground = P.base0, bold = true },
    commentTSNote = { background = P.blue, foreground = P.base0, bold = true },

    DiagnosticError = { foreground = P.error_red },
    DiagnosticWarning = { foreground = P.dark_orange },
    DiagnosticInfo = { foreground = P.blue },
    DiagnosticHint = { foreground = P.darker_green },
    LspCodeLens = { link = "NonText" },
    LspReferenceText = { underline = true, background = "NONE" },
    LspReferenceRead = { underline = true, background = "NONE" },
    -- This represents when a reference is assigned which is more interesting than regular
    -- occurrences so should be highlighted more distinctly
    LspReferenceWrite = { underline = true, bold = true, italic = true, background = "NONE" },
    DiagnosticVirtualTextError = { background = util.alter_color(P.pale_red, -80) },
    DiagnosticVirtualTextWarn = { background = util.alter_color(P.dark_orange, -80) },
    DiagnosticVirtualTextInfo = { background = util.alter_color(P.pale_blue, -80) },
    DiagnosticVirtualTextHint = { background = util.alter_color(P.darker_green, -80) },

    -- Matchup
    MatchWord = { fg = P.red, underline = false, cterm = { underline = false } },
  })
end

local function set_sidebar_highlight()
  -- local normal_bg = rvim.util.transparent_window and "NONE" or M.get("Normal", "bg")..
  local split_color = util.get("VertSplit", "fg")
  local bg_color = util.alter_color(P.bg, -20)
  local st_color = util.alter_color(util.get("Visual", "bg"), -10)
  util.all({
    PanelBackground = { link = "Normal" },
    PanelHeading = { background = bg_color, bold = true },
    PanelVertSplit = { foreground = split_color, background = bg_color },
    PanelVertSplitAlt = { foreground = bg_color, background = bg_color },
    PanelWinSeparator = { foreground = split_color, background = bg_color },
    PanelStNC = { background = st_color, cterm = { italic = true } },
    PanelSt = { background = st_color },
  })
end

local sidebar_fts = {
  "packer",
  "flutterToolsOutline",
  "undotree",
  "NvimTree",
  "neo-tree",
  "qf",
  "neotest-summary",
}

local function on_sidebar_enter()
  vim.wo.winhighlight = table.concat({
    "Normal:PanelBackground",
    "EndOfBuffer:PanelBackground",
    "StatusLine:PanelSt",
    "StatusLineNC:PanelStNC",
    "SignColumn:PanelBackground",
    "VertSplit:PanelVertSplit",
  }, ",")
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
end

rvim.augroup("UserHighlights", {
  {
    event = "ColorScheme",
    command = function()
      user_highlights()
    end,
  },
  {
    event = "FileType",
    pattern = sidebar_fts,
    command = function()
      on_sidebar_enter()
    end,
  },
})

-----------------------------------------------------------------------------//
-- Color Scheme {{{1
-----------------------------------------------------------------------------//
vim.g.colors_name = rvim.colorscheme
vim.cmd("colorscheme " .. rvim.colorscheme)
