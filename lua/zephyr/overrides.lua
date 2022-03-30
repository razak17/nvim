local P = rvim.palette
local util = require "zephyr.util"

local function general_overrides()
  local comment_fg = util.get_hl("Comment", "fg")
  local keyword_fg = util.get_hl("Keyword", "fg")
  local search_bg = util.get_hl("Search", "bg")
  -- local error_line = util.alter_color(P.error_red, -80)
  local msg_area_bg = rvim.util.transparent_window and "NONE" or P.darker_bg
  util.all {
    -- { "VertSplit", { background = "NONE", foreground = util.get_hl("NonText", "fg") } },
    -- { "WinSeparator", { background = "NONE", foreground = util.get_hl("NonText", "fg") } },
    { "MsgArea", { background = msg_area_bg } },
    { "mkdLineBreak", { link = "NONE" } },
    -----------------------------------------------------------------------------//
    -- Floats
    -----------------------------------------------------------------------------//
    { "NormalFloat", { background = P.bg } },
    -----------------------------------------------------------------------------//
    { "CursorLineNr", { bold = true } },
    { "FoldColumn", { background = "background" } },
    { "TermCursor", { ctermfg = "green", foreground = "royalblue" } },
    -- Add undercurl to existing spellbad highlight
    { "SpellBad", { undercurl = true, background = "NONE", foreground = "NONE", sp = "green" } },
    { "SpellRare", { undercurl = true } },
    -----------------------------------------------------------------------------//
    -- colorscheme overrides
    -----------------------------------------------------------------------------//
    -- { "Comment", { italic = true } },
    { "Include", { italic = true } },
    -- { "Type", { italic = true, bold = true } },
    {
      "Folded",
      {
        background = "NONE",
        foreground = comment_fg,
        bold = true,
        -- italic = true,
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
    -- { "TSError", { undercurl = true, sp = error_line, foreground = "NONE" } },
    { "TSParameter", { italic = true, bold = true, foreground = "NONE" } },
    -- highlight FIXME comments
    { "commentTSWarning", { background = P.error_red, foreground = "fg", bold = true } },
    { "commentTSDanger", { background = P.dark_green, foreground = "#1B2229", bold = true } },
    { "commentTSNote", { background = P.bluee, foreground = "#1B2229", bold = true } },
  }
end

local function set_sidebar_highlight()
  -- local normal_bg = rvim.util.transparent_window and "NONE" or M.get_hl("Normal", "bg")..
  local split_color = util.get_hl("VertSplit", "fg")
  local bg_color = util.alter_color(P.bg, -20)
  local st_color = util.alter_color(util.get_hl("Visual", "bg"), -10)
  local hls = {
    { "PanelBackground", { link = "Normal" } },
    { "PanelHeading", { background = bg_color, bold = true } },
    { "PanelVertSplit", { foreground = split_color, background = bg_color } },
    { "PanelVertSplitAlt", { foreground = bg_color, background = bg_color } },
    { "PanelWinSeparator", { foreground = split_color, background = bg_color } },
    { "PanelStNC", { background = st_color, cterm = { italic = true } } },
    { "PanelSt", { background = st_color } },
  }
  for _, grp in ipairs(hls) do
    util.set_hl(unpack(grp))
  end
end

local sidebar_fts = {
  "packer",
  "flutterToolsOutline",
  "undotree",
  "NvimTree",
  -- FIXME: causes error when adding to qflist from telescope
  -- "qf",
}

local function on_sidebar_enter()
  vim.wo.winhighlight = table.concat({
    "Normal:PanelBackground",
    "EndOfBuffer:PanelBackground",
    "StatusLine:PanelSt",
    "StatusLineNC:PanelStNC",
    "SignColumn:PanelBackground",
    "VertSplit:PanelVertSplit",
    "WinSeparator:PanelWinSeparator",
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
vim.cmd "colorscheme zephyr"
