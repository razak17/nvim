-- Theme: P
-- Author: Glepnir
-- License: MIT
-- Source: http://github.com/glepnir/zephyr-nvim
local P = rvim.palette

local zephyr = {}

function zephyr.terminal_color()
  vim.g.terminal_color_0 = P.bg
  vim.g.terminal_color_1 = P.red
  vim.g.terminal_color_2 = P.green
  vim.g.terminal_color_3 = P.yellow
  vim.g.terminal_color_4 = P.blue
  vim.g.terminal_color_5 = P.violet
  vim.g.terminal_color_6 = P.cyan
  vim.g.terminal_color_7 = P.bg_visual
  vim.g.terminal_color_8 = P.brown
  vim.g.terminal_color_9 = P.red
  vim.g.terminal_color_10 = P.green
  vim.g.terminal_color_11 = P.yellow
  vim.g.terminal_color_12 = P.blue
  vim.g.terminal_color_13 = P.violet
  vim.g.terminal_color_14 = P.cyan
  vim.g.terminal_color_15 = P.fg
end

function zephyr.highlight(group, color)
  local style = color.style and "gui=" .. color.style or "gui=NONE"
  local fg = color.fg and "guifg=" .. color.fg or "guifg=NONE"
  local bg = color.bg and "guibg=" .. color.bg or "guibg=NONE"
  local sp = color.sp and "guisp=" .. color.sp or ""
  vim.api.nvim_command("highlight " .. group .. " " .. style .. " " .. fg .. " " .. bg .. " " .. sp)
end

function zephyr.load_syntax()
  local syntax = {
    Normal = { fg = P.fg, bg = P.bg },
    NormalNC = { fg = P.fg, bg = P.none },
    Terminal = { fg = P.fg, bg = P.bg },
    SignColumn = { fg = P.fg, bg = P.bg },
    FoldColumn = { fg = P.fg_alt, bg = P.black },
    VertSplit = { fg = P.bg, bg = P.bg },
    Folded = { fg = P.grey, bg = P.highlight_bg },
    EndOfBuffer = { fg = P.bg, bg = P.none },
    IncSearch = { fg = P.bg, bg = P.orange, style = zephyr.none },
    Search = { fg = P.bg, bg = P.orange },
    Conceal = { fg = P.grey, bg = P.none },
    Cursor = { fg = P.none, bg = P.none, style = "reverse" },
    vCursor = { fg = P.none, bg = P.none, style = "reverse" },
    iCursor = { fg = P.none, bg = P.none, style = "reverse" },
    lCursor = { fg = P.none, bg = P.none, style = "reverse" },
    ColorColumn = { fg = P.none, bg = P.dark_alt },
    CursorIM = { fg = P.none, bg = P.none, style = "reverse" },
    CursorColumn = { fg = P.none, bg = P.dark_alt },
    CursorLine = { fg = P.none, bg = P.dark_alt },
    LineNr = { fg = P.base5, bg = P.none },
    qfLineNr = { fg = P.cyan },
    qfFileName = { fg = P.yellowgreen },
    CursorLineNr = { fg = P.pink, style = "bold" },
    netrwDir = { fg = P.pink },
    DiffAdd = { fg = P.black, bg = P.dark_green },
    DiffChange = { fg = P.black, bg = P.yellow },
    DiffDelete = { fg = P.black, bg = P.red },
    DiffText = { fg = P.black, bg = P.fg },
    Directory = { fg = P.blue, bg = P.none },
    ErrorMsg = { fg = P.red, bg = P.none, style = "bold" },
    WarningMsg = { fg = P.yellow, bg = P.none, style = "bold" },
    ModeMsg = { fg = P.fg, bg = P.none, style = "bold" },
    MatchParen = { fg = P.red, bg = P.none },
    NonText = { fg = P.bg },
    Whitespace = { fg = P.base4 },
    SpecialKey = { fg = P.bg },
    Pmenu = { fg = P.fg, bg = P.bg_popup },
    PmenuSel = { fg = P.base0, bg = P.blue },
    PmenuSelBold = { fg = P.base0, g = P.blue },
    PmenuSbar = { fg = P.none, bg = P.base4 },
    PmenuThumb = { fg = P.violet, bg = P.light_green },
    WildMenu = { fg = P.fg, bg = P.green },
    Question = { fg = P.yellow },
    NormalFloat = { fg = P.base8, bg = P.bg_highlight },
    TabLineFill = { style = P.none },
    TabLineSel = { bg = P.blue },
    StatusLine = { fg = P.base8, bg = P.base2, style = zephyr.none },
    StatusLineNC = { fg = P.grey, bg = P.base2, style = zephyr.none },
    SpellBad = { fg = P.red, bg = P.none, style = "undercurl" },
    SpellCap = { fg = P.blue, bg = P.none, style = "undercurl" },
    SpellLocal = { fg = P.cyan, bg = P.none, style = "undercurl" },
    SpellRare = { fg = P.violet, bg = P.none, style = "undercurl" },
    Visual = { fg = P.black, bg = P.bracket },
    VisualNOS = { fg = P.black, bg = P.bracket },
    QuickFixLine = { fg = P.black },
    Debug = { fg = P.orange },
    debugBreakpoint = { fg = P.bg, bg = P.red },

    Boolean = { fg = P.orange },
    Number = { fg = P.brown },
    Float = { fg = P.brown },
    PreProc = { fg = P.violet },
    PreCondit = { fg = P.violet },
    Include = { fg = P.violet },
    Define = { fg = P.violet },
    Conditional = { fg = P.magenta },
    Repeat = { fg = P.magenta },
    Keyword = { fg = P.green },
    Typedef = { fg = P.red },
    Exception = { fg = P.red },
    Statement = { fg = P.red },
    Error = { fg = P.red },
    StorageClass = { fg = P.orange },
    Tag = { fg = P.orange },
    Label = { fg = P.orange },
    Structure = { fg = P.orange },
    Operator = { fg = P.redwine },
    Title = { fg = P.orange, style = "bold" },
    Special = { fg = P.yellow },
    SpecialChar = { fg = P.yellow },
    Type = { fg = P.teal },
    Function = { fg = P.yellow },
    String = { fg = P.light_green },
    Character = { fg = P.green },
    Constant = { fg = P.cyan },
    Macro = { fg = P.cyan },
    Identifier = { fg = P.blue },

    Comment = { fg = P.base6 },
    SpecialComment = { fg = P.grey },
    Todo = { fg = P.orange, style = "italic" },
    Delimiter = { fg = P.fg },
    Ignore = { fg = P.grey },
    Underlined = { fg = P.none, style = "underline" },
  }
  return syntax
end

function zephyr.load_plugin_syntax()
  local plugin_syntax = {
    TSFunction = { fg = P.cyan },
    TSComment = { fg = P.dark },
    TSMethod = { fg = P.cyan },
    TSKeywordFunction = { fg = P.red },
    TSProperty = { fg = P.yellow },
    TSType = { fg = P.teal },
    TSVariable = { fg = P.blue },
    TSPunctBracket = { fg = P.bracket },

    vimCommentTitle = { fg = P.grey, style = "bold" },
    vimLet = { fg = P.orange },
    vimVar = { fg = P.cyan },
    vimFunction = { fg = P.redwine },
    vimIsCommand = { fg = P.fg },
    vimCommand = { fg = P.blue },
    vimNotFunc = { fg = P.violet, style = "bold" },
    vimUserFunc = { fg = P.yellow, style = "bold" },
    vimFuncName = { fg = P.yellow, style = "bold" },

    diffAdded = { fg = P.dark_green },
    diffRemoved = { fg = P.red },
    diffChanged = { fg = P.blue },
    diffOldFile = { fg = P.yellow },
    diffNewFile = { fg = P.orange },
    diffFile = { fg = P.aqua },
    diffLine = { fg = P.grey },
    diffIndexLine = { fg = P.violet },

    gitcommitSummary = { fg = P.red },
    gitcommitUntracked = { fg = P.grey },
    gitcommitDiscarded = { fg = P.grey },
    gitcommitSelected = { fg = P.grey },
    gitcommitUnmerged = { fg = P.grey },
    gitcommitOnBranch = { fg = P.grey },
    gitcommitArrow = { fg = P.grey },
    gitcommitFile = { fg = P.dark_green },

    GitGutterAdd = { fg = P.dark_green },
    GitGutterChange = { fg = P.blue },
    GitGutterDelete = { fg = P.red },
    GitGutterChangeDelete = { fg = P.violet },

    GitSignsAdd = { fg = P.dark_green },
    GitSignsChange = { fg = P.blue },
    GitSignsDelete = { fg = P.red },
    GitSignsAddNr = { fg = P.dark_green },
    GitSignsChangeNr = { fg = P.blue },
    GitSignsDeleteNr = { fg = P.red },
    GitSignsAddLn = { bg = P.bg_popup },
    GitSignsChangeLn = { bg = P.bg_highlight },
    GitSignsDeleteLn = { bg = P.bg },

    SignifySignAdd = { fg = P.dark_green },
    SignifySignChange = { fg = P.blue },
    SignifySignDelete = { fg = P.red },

    dbui_tables = { fg = P.blue },

    DiagnosticError = { fg = P.pale_red },
    DiagnosticWarning = { fg = P.dark_orange },
    DiagnosticInfo = { fg = P.blue },
    DiagnosticHint = { fg = P.teal },

    LspDiagnosticsError = { fg = P.pale_red },
    LspDiagnosticsWarning = { fg = P.dark_orange },
    LspDiagnosticsInformation = { fg = P.blue },
    LspDiagnosticsHint = { fg = P.teal },

    DiagnosticsSignErrorLine = { fg = P.pale_red },
    DiagnosticsSignWarnLine = { fg = P.dark_orange },
    DiagnosticsSignInfoLine = { fg = P.blue },
    DiagnosticsSignHintLine = { fg = P.teal },

    DiagnosticSignError = { fg = P.pale_red },
    DiagnosticSignWarn = { fg = P.dark_orange },
    DiagnosticSignInfo = { fg = P.blue },
    DiagnosticSignHint = { fg = P.teal },

    DiagnosticFloatingError = { fg = P.pale_red },
    DiagnosticFloatingWarn = { fg = P.dark_orange },
    DiagnosticFloatingInfo = { fg = P.blue },
    DiagnosticFloatingHint = { fg = P.teal },

    LspDiagnosticsFloatingError = { fg = P.pale_red },
    LspDiagnosticsFloatingWarning = { fg = P.dark_orange },
    LspDiagnosticsFloatingInformation = { fg = P.blue },
    LspDiagnosticsFloatingHint = { fg = P.teal },

    DiagnosticUnderlineError = { style = "undercurl", sp = P.pale_red },
    DiagnosticUnderlineWarn = { style = "undercurl", sp = P.dark_orange },
    DiagnosticUnderlineInfo = { style = "undercurl", sp = P.blue },
    DiagnosticUnderlineHint = { style = "undercurl", sp = P.teal },

    LspDiagnosticsVirtualTextError = { fg = P.pale_red },
    LspDiagnosticsVirtualTextWarning = { fg = P.dark_orange },
    LspDiagnosticsVirtualTextInformation = { fg = P.blue },
    LspDiagnosticsVirtualTextHint = { fg = P.teal },

    LspReferenceRead = { bg = P.base4 },
    LspReferenceText = { bg = P.base4 },
    LspReferenceWrite = { bg = P.base4 },

    TroubleCount = { bg = P.highlight_bg, fg = P.magenta },
    TroubleFile = { fg = P.blue, style = "bold" },
    TroubleTextError = { fg = P.red },
    TroubleTextWarning = { fg = P.yellow },
    TroubleTextInformation = { fg = P.blue },
    TroubleTextHint = { fg = P.teal },

    BqfPreviewBorder = { fg = P.blue },
    BqfSign = { fg = P.red },
    BqfPreviewRange = "fg = P.red",

    CursorWord0 = { bg = P.cursor_bg },
    CursorWord1 = { bg = P.none },
    CursorWord = { bg = P.none },

    -- NvimTreeNormal = { bg = P.alt_bg },
    -- NvimTreeNormalNC = { bg = P.alt_bg },
    -- NvimTreeSignColumn = { bg = P.alt_bg },
    -- NvimTreeEndOfBuffer = { bg = P.alt_bg },
    NvimTreeFolderIcon = { fg = P.blue },
    NvimTreeIndentMarker = { fg = P.base6 },
    NvimTreeVertSplit = { fg = P.blue, bg = P.yellow },
    NvimTreeImageFile = { fg = P.purple },
    NvimTreeSpecialFile = { fg = P.orange },
    NvimTreeGitStaged = { fg = P.sign_add },
    NvimTreeCursorLine = { bg = P.red },
    NvimTreeGitNew = { fg = P.sign_add },
    NvimTreeGitDirty = { fg = P.sign_add },
    NvimTreeGitDeleted = { fg = P.sign_delete },
    NvimTreeGitMerge = { fg = P.sign_change },
    NvimTreeGitRenamed = { fg = P.sign_change },
    NvimTreeSymlink = { fg = P.cyan },
    NvimTreeExecFile = { fg = P.green },
    NvimTreeFolderName = { fg = P.blue },
    NvimTreeEmptyFolderName = { fg = P.base5 },
    NvimTreeRootFolder = { fg = P.base5, style = "bold" },
    NvimTreeOpenedFolderName = { fg = P.base5 },

    TelescopeNormal = { fg = P.fg },
    TelescopeBorder = { fg = P.blue2, bg = P.bg },
    TelescopeResultsBorder = { fg = P.blue2, bg = P.bg },
    TelescopePromptBorder = { fg = P.blue2, bg = P.bg },
    TelescopePreviewBorder = { fg = P.magenta, bg = P.bg },
    TelescopeMatching = { fg = P.yellowgreen, style = "bold" },
    TelescopeSelection = { fg = P.cyan, style = "bold" },
    TelescopeSelectionCaret = { fg = P.yellow },
    TelescopeMultiSelection = { fg = P.light_green },
    TelescopePromptPrefix = { fg = P.yellow },

    FloatermBorder = { fg = P.blue2, bg = P.bg },

    DashboardShortCut = { fg = P.blue4 },
    DashboardHeader = { fg = P.blue2 },
    DashboardCenter = { fg = P.blue2 },
    DashboardFooter = { fg = P.cyan2, style = "bold" },

    WhichKey = { fg = P.blue2 },
    WhichKeyName = { fg = P.pink },
    WhichKeyTrigger = { fg = P.black },
    WhichKeyFloating = { fg = P.red },
    WhichKeySeperator = { fg = P.blue3 },
    WhichKeyGroup = { fg = P.blue2 },
    WhichKeyDesc = { fg = P.blue3 },
  }
  return plugin_syntax
end

local async_load_plugin

async_load_plugin = vim.loop.new_async(vim.schedule_wrap(function()
  zephyr.terminal_color()
  local syntax = zephyr.load_plugin_syntax()
  for group, colors in pairs(syntax) do
    zephyr.highlight(group, colors)
  end
  async_load_plugin:close()
end))

function zephyr.colorscheme()
  vim.api.nvim_command "hi clear"
  if vim.fn.exists "syntax_on" then
    vim.api.nvim_command "syntax reset"
  end
  vim.o.background = "dark"
  vim.o.termguicolors = true
  vim.g.colors_name = "P"
  local syntax = zephyr.load_syntax()
  for group, colors in pairs(syntax) do
    zephyr.highlight(group, colors)
  end
  async_load_plugin:send()
end

zephyr.colorscheme()

return zephyr
