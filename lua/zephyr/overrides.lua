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
    { "MsgArea", { guibg = msg_area_bg } },
    { "mkdLineBreak", { link = "NONE", force = true } },
    -----------------------------------------------------------------------------//
    -- Floats
    -----------------------------------------------------------------------------//
    { "NormalFloat", { link = "Normal" } },
    --- Highlight group for light coloured floats
    { "GreyFloat", { guibg = P.grey } },
    { "GreyFloatBorder", { guifg = P.grey } },
    -----------------------------------------------------------------------------//
    { "CursorLineNr", { gui = "bold" } },
    { "FoldColumn", { guibg = "background" } },
    { "Folded", { guifg = comment_fg, guibg = "NONE", gui = "italic" } },
    { "TermCursor", { ctermfg = "green", guifg = "royalblue" } },
    { "IncSearch", { guibg = "NONE", guifg = "LightGreen", gui = "bold,underline" } },
    -- Add undercurl to existing spellbad highlight
    -- {
    --   "SpellBad",
    --   { gui = "undercurl", guibg = "transparent", guifg = "transparent", guisp = "green" },
    -- },
    -----------------------------------------------------------------------------//
    -- colorscheme overrides
    -----------------------------------------------------------------------------//
    { "Comment", { gui = "italic" } },
    { "Include", { gui = "italic" } },
    -- { "Type", { gui = "italic,bold" } },
    -- { "Folded", { gui = "bold,italic" } },
    { "QuickFixLine", { guibg = search_bg } },
    { "Visual", { guifg = "NONE", guibg = util.alter_color(P.pale_blue, -50) } },
    -----------------------------------------------------------------------------//
    -- Treesitter
    -----------------------------------------------------------------------------//
    { "TSKeywordReturn", { gui = "italic", guifg = keyword_fg } },
    { "TSError", { link = "LspDiagnosticsUnderlineError", force = true } },
    -- { "TSParameter", { gui = "italic,bold" } },
    -- highlight FIXME comments
    { "commentTSWarning", { guifg = "Red", gui = "bold" } },
    { "commentTSDanger", { guifg = P.danger, gui = "bold" } },
  }
end

local function set_sidebar_highlight()
  -- local normal_bg = rvim.common.transparent_window and "NONE" or M.get_hl("Normal", "bg")..
  local split_color = util.get_hl("VertSplit", "fg")
  local bg_color = P.bg
  local st_color = util.alter_color(util.get_hl("Visual", "bg"), -10)
  local hls = {
    { "PanelBackground", { link = "Normal" } },
    { "PanelHeading", { guibg = bg_color, gui = "bold" } },
    { "PanelVertSplit", { guifg = split_color, guibg = bg_color } },
    { "PanelVertSplitAlt", { guifg = bg_color, guibg = bg_color } },
    { "PanelStNC", { guibg = st_color, cterm = "italic" } },
    { "PanelSt", { guibg = st_color } },
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
