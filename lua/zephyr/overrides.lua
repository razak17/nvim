local P = rvim.palette
local util = require "zephyr.util"

local function general_overrides()
  local comment_fg = util.get_hl("Comment", "fg")
  local keyword_fg = util.get_hl("Keyword", "fg")
  local search_bg = util.get_hl("Search", "bg")
  local normal_bg = util.get_hl("Normal", "bg")
  local darker_bg = util.alter_color(normal_bg, -10)
  local msg_area_bg = rvim.common.transparent_window and "NONE" or darker_bg
  util.all {
    { "MsgArea", { background = msg_area_bg } },
    { "mkdLineBreak", { link = "NONE" } },
    -----------------------------------------------------------------------------//
    -- Floats
    -----------------------------------------------------------------------------//
    { "NormalFloat", { background = P.bg } },
    --- Highlight group for light coloured floats
    { "GreyFloat", { background = P.grey } },
    { "GreyFloatBorder", { foreground = P.grey } },
    -----------------------------------------------------------------------------//
    { "CursorLineNr", { bold = true } },
    { "FoldColumn", { background = "background" } },
    { "TermCursor", { ctermfg = "green", foreground = "royalblue" } },
    {
      "IncSearch",
      {
        background = "NONE",
        foreground = "LightGreen",
        italic = true,
        bold = true,
        underline = true,
      },
    },
    -- Add undercurl to existing spellbad highlight
    -- { 'SpellBad', { undercurl = true, background = 'NONE', foreground = 'NONE', sp = 'green' } },
    -----------------------------------------------------------------------------//
    -- colorscheme overrides
    -----------------------------------------------------------------------------//
    { "Comment", { italic = true } },
    { "Include", { italic = true } },
    -- { "Type", { italic = true, bold = true } },
    -- { "Folded", { italic = true, bold = true } },
    {
      "Folded",
      {
        background = "NONE",
        foreground = comment_fg,
        italic = true,
      },
    },
    { "QuickFixLine", { background = search_bg } },
    {
      "Visual",
      {
        foreground = "NONE",
        background = util.alter_color(P.pale_blue, -50),
      },
    },
    -----------------------------------------------------------------------------//
    -- Treesitter
    -----------------------------------------------------------------------------//
    { "TSKeywordReturn", { italic = true, foreground = keyword_fg } },
    { "TSError", { link = "LspDiagnosticsUnderlineError" } },
    -- { "TSParameter", { italic = true, bold = true } },
    -- highlight FIXME comments
    { "commentTSWarning", { foreground = "Red", bold = true } },
    { "commentTSDanger", { foreground = P.danger, bold = true } },
  }
end

local function set_sidebar_highlight()
  -- local normal_bg = rvim.common.transparent_window and "NONE" or M.get_hl("Normal", "bg")..
  local split_color = util.get_hl("VertSplit", "fg")
  local bg_color = P.bg
  local st_color = util.alter_color(util.get_hl("Visual", "bg"), -10)
  local hls = {
    { "PanelBackground", { link = "Normal" } },
    { "PanelHeading", { background = bg_color, bold = true } },
    { "PanelVertSplit", { foreground = split_color, background = bg_color } },
    { "PanelVertSplitAlt", { foreground = bg_color, background = bg_color } },
    { "PanelStNC", { background = st_color, cterm = { italic = true } } },
    { "PanelSt", { background = st_color } },
  }
  for _, grp in ipairs(hls) do
    util.set_hl(unpack(grp))
  end
end

local sidebar_fts = {
  "packer",
  "dap-repl",
  "flutterToolsOutline",
  "undotree",
  "NvimTree",
  "dapui_*",
}

local function on_sidebar_enter()
  vim.wo.winhighlight = table.concat({
    "Normal:PanelBackground",
    "EndOfBuffer:PanelBackground",
    "StatusLine:PanelSt",
    "StatusLineNC:PanelStNC",
    "SignColumn:PanelBackground",
    "VertSplit:PanelBackground",
  }, ",")
end

local function user_highlights()
  general_overrides()
  set_sidebar_highlight()
end

rvim.augroup("UserHighlights", {
  {
    events = { "ColorScheme" },
    targets = { "*" },
    command = user_highlights,
  },
  {
    events = { "FileType" },
    targets = sidebar_fts,
    command = on_sidebar_enter,
  },
})

-----------------------------------------------------------------------------//
-- Color Scheme {{{1
-----------------------------------------------------------------------------//
vim.cmd "colorscheme zephyr"
