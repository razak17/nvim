-- Theme: zephyr
-- Author: Glepnir
-- License: MIT
-- Source: http://github.com/glepnir/zephyr-nvim
local zephyr = {
  base0 = "#1B2229",
  base1 = "#1c1f24",
  base2 = "#202328",
  base3 = "#23272e",
  base4 = "#3f444a",
  base5 = "#5B6268",
  base6 = "#73797e",
  base7 = "#9ca0a4",
  base8 = "#b1b1b1",

  base99 = "#293238",

  bg = "#282a36",
  bg1 = "#504945",
  dark = "#5c6370",
  dark2 = "#373d48",
  bg_popup = "#3e4556",
  bg_highlight = "#2E323C",
  bg_highlight2 = "#4E525C",
  bg_visual = "#b3deef",

  fg = "#bbc2cf",
  fg_alt = "#5B6268",

  pale_red = "#e06c75",
  dark_orange = "#ff922b",
  light_green = "#abcf84",

  red = "#e95678",
  redwine = "#d16d9e",
  orange = "#D98E48",
  yellow = "#f0c674",
  yellowgreen = "#aed75f",
  pink = "#c678dd",

  green = "#afd700",
  dark_green = "#98be65",

  cyan = "#14ffff",
  cyan2 = "#65a7c5",
  blue = "#51afef",
  blue2 = "#7ec0ee",
  blue3 = "#9cd0fa",
  blue4 = "#7685b1",
  blue5 = "#5486c0",
  violet = "#b294bb",
  magenta = "#c678dd",
  -- teal = "#1abc9c",
  teal = "#15aabf",
  grey = "#928374",
  brown = "#c78665",
  black = "#000000",

  bracket = "#80a0c2",
  cursor_bg = "#4f5b66",
  none = "NONE",
}

function zephyr.terminal_color()
  vim.g.terminal_color_0 = zephyr.bg
  vim.g.terminal_color_1 = zephyr.red
  vim.g.terminal_color_2 = zephyr.green
  vim.g.terminal_color_3 = zephyr.yellow
  vim.g.terminal_color_4 = zephyr.blue
  vim.g.terminal_color_5 = zephyr.violet
  vim.g.terminal_color_6 = zephyr.cyan
  vim.g.terminal_color_7 = zephyr.bg_visual
  vim.g.terminal_color_8 = zephyr.brown
  vim.g.terminal_color_9 = zephyr.red
  vim.g.terminal_color_10 = zephyr.green
  vim.g.terminal_color_11 = zephyr.yellow
  vim.g.terminal_color_12 = zephyr.blue
  vim.g.terminal_color_13 = zephyr.violet
  vim.g.terminal_color_14 = zephyr.cyan
  vim.g.terminal_color_15 = zephyr.fg
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
    Normal = { fg = zephyr.fg, bg = zephyr.bg },
    NormalNC = { fg = zephyr.fg, bg = zephyr.none },
    Terminal = { fg = zephyr.fg, bg = zephyr.bg },
    SignColumn = { fg = zephyr.fg, bg = zephyr.bg },
    FoldColumn = { fg = zephyr.fg_alt, bg = zephyr.black },
    VertSplit = { fg = zephyr.black, bg = zephyr.bg },
    Folded = { fg = zephyr.grey, bg = zephyr.bg_highlight2 },
    EndOfBuffer = { fg = zephyr.bg, bg = zephyr.none },
    IncSearch = { fg = zephyr.bg1, bg = zephyr.orange, style = zephyr.none },
    Search = { fg = zephyr.bg, bg = zephyr.orange },
    Conceal = { fg = zephyr.grey, bg = zephyr.none },
    Cursor = { fg = zephyr.none, bg = zephyr.none, style = "reverse" },
    vCursor = { fg = zephyr.none, bg = zephyr.none, style = "reverse" },
    iCursor = { fg = zephyr.none, bg = zephyr.none, style = "reverse" },
    lCursor = { fg = zephyr.none, bg = zephyr.none, style = "reverse" },
    ColorColumn = { fg = zephyr.none, bg = zephyr.dark2 },
    CursorIM = { fg = zephyr.none, bg = zephyr.none, style = "reverse" },
    CursorColumn = { fg = zephyr.none, bg = zephyr.dark2 },
    CursorLine = { fg = zephyr.none, bg = zephyr.dark2 },
    LineNr = { fg = zephyr.base5, bg = zephyr.none },
    qfLineNr = { fg = zephyr.cyan },
    CursorLineNr = { fg = zephyr.pink, style = "bold" },
    netrwDir = { fg = zephyr.pink },
    qfFileName = { fg = zephyr.yellowgreen },
    DiffAdd = { fg = zephyr.black, bg = zephyr.dark_green },
    DiffChange = { fg = zephyr.black, bg = zephyr.yellow },
    DiffDelete = { fg = zephyr.black, bg = zephyr.red },
    DiffText = { fg = zephyr.black, bg = zephyr.fg },
    Directory = { fg = zephyr.blue, bg = zephyr.none },
    ErrorMsg = { fg = zephyr.red, bg = zephyr.none, style = "bold" },
    WarningMsg = { fg = zephyr.yellow, bg = zephyr.none, style = "bold" },
    ModeMsg = { fg = zephyr.fg, bg = zephyr.none, style = "bold" },
    MatchParen = { fg = zephyr.red, bg = zephyr.none },
    NonText = { fg = zephyr.bg1 },
    Whitespace = { fg = zephyr.base4 },
    SpecialKey = { fg = zephyr.bg1 },
    Pmenu = { fg = zephyr.fg, bg = zephyr.bg_popup },
    PmenuSel = { fg = zephyr.base0, bg = zephyr.blue },
    PmenuSelBold = { fg = zephyr.base0, g = zephyr.blue },
    PmenuSbar = { fg = zephyr.none, bg = zephyr.base4 },
    PmenuThumb = { fg = zephyr.violet, bg = zephyr.light_green },
    WildMenu = { fg = zephyr.fg, bg = zephyr.green },
    Question = { fg = zephyr.yellow },
    NormalFloat = { fg = zephyr.base8, bg = zephyr.bg_highlight },
    TabLineFill = { style = zephyr.none },
    TabLineSel = { bg = zephyr.blue },
    StatusLine = { fg = zephyr.base8, bg = zephyr.base2, style = zephyr.none },
    StatusLineNC = { fg = zephyr.grey, bg = zephyr.base2, style = zephyr.none },
    SpellBad = { fg = zephyr.red, bg = zephyr.none, style = "undercurl" },
    SpellCap = { fg = zephyr.blue, bg = zephyr.none, style = "undercurl" },
    SpellLocal = { fg = zephyr.cyan, bg = zephyr.none, style = "undercurl" },
    SpellRare = { fg = zephyr.violet, bg = zephyr.none, style = "undercurl" },
    Visual = { fg = zephyr.black, bg = zephyr.bracket },
    VisualNOS = { fg = zephyr.black, bg = zephyr.bracket },
    QuickFixLine = { fg = zephyr.violet, style = "bold" },
    Debug = { fg = zephyr.orange },
    debugBreakpoint = { fg = zephyr.bg, bg = zephyr.red },

    Boolean = { fg = zephyr.orange },
    Number = { fg = zephyr.brown },
    Float = { fg = zephyr.brown },
    PreProc = { fg = zephyr.violet },
    PreCondit = { fg = zephyr.violet },
    Include = { fg = zephyr.violet },
    Define = { fg = zephyr.violet },
    Conditional = { fg = zephyr.magenta },
    Repeat = { fg = zephyr.magenta },
    Keyword = { fg = zephyr.green },
    Typedef = { fg = zephyr.red },
    Exception = { fg = zephyr.red },
    Statement = { fg = zephyr.red },
    Error = { fg = zephyr.red },
    StorageClass = { fg = zephyr.orange },
    Tag = { fg = zephyr.orange },
    Label = { fg = zephyr.orange },
    Structure = { fg = zephyr.orange },
    Operator = { fg = zephyr.redwine },
    Title = { fg = zephyr.orange, style = "bold" },
    Special = { fg = zephyr.yellow },
    SpecialChar = { fg = zephyr.yellow },
    Type = { fg = zephyr.teal },
    Function = { fg = zephyr.yellow },
    String = { fg = zephyr.light_green },
    Character = { fg = zephyr.green },
    Constant = { fg = zephyr.cyan },
    Macro = { fg = zephyr.cyan },
    Identifier = { fg = zephyr.blue },

    Comment = { fg = zephyr.base6 },
    SpecialComment = { fg = zephyr.grey },
    Todo = { fg = zephyr.orange, style = "italic" },
    Delimiter = { fg = zephyr.fg },
    Ignore = { fg = zephyr.grey },
    Underlined = { fg = zephyr.none, style = "underline" },
  }
  return syntax
end

function zephyr.load_plugin_syntax()
  local plugin_syntax = {
    TSFunction = { fg = zephyr.cyan },
    TSComment = { fg = zephyr.dark },
    TSMethod = { fg = zephyr.cyan },
    TSKeywordFunction = { fg = zephyr.red },
    TSProperty = { fg = zephyr.yellow },
    TSType = { fg = zephyr.teal },
    TSVariable = { fg = zephyr.blue },
    TSPunctBracket = { fg = zephyr.bracket },

    vimCommentTitle = { fg = zephyr.grey, style = "bold" },
    vimLet = { fg = zephyr.orange },
    vimVar = { fg = zephyr.cyan },
    vimFunction = { fg = zephyr.redwine },
    vimIsCommand = { fg = zephyr.fg },
    vimCommand = { fg = zephyr.blue },
    vimNotFunc = { fg = zephyr.violet, style = "bold" },
    vimUserFunc = { fg = zephyr.yellow, style = "bold" },
    vimFuncName = { fg = zephyr.yellow, style = "bold" },

    diffAdded = { fg = zephyr.dark_green },
    diffRemoved = { fg = zephyr.red },
    diffChanged = { fg = zephyr.blue },
    diffOldFile = { fg = zephyr.yellow },
    diffNewFile = { fg = zephyr.orange },
    diffFile = { fg = zephyr.aqua },
    diffLine = { fg = zephyr.grey },
    diffIndexLine = { fg = zephyr.violet },

    gitcommitSummary = { fg = zephyr.red },
    gitcommitUntracked = { fg = zephyr.grey },
    gitcommitDiscarded = { fg = zephyr.grey },
    gitcommitSelected = { fg = zephyr.grey },
    gitcommitUnmerged = { fg = zephyr.grey },
    gitcommitOnBranch = { fg = zephyr.grey },
    gitcommitArrow = { fg = zephyr.grey },
    gitcommitFile = { fg = zephyr.dark_green },

    GitGutterAdd = { fg = zephyr.dark_green },
    GitGutterChange = { fg = zephyr.blue },
    GitGutterDelete = { fg = zephyr.red },
    GitGutterChangeDelete = { fg = zephyr.violet },

    GitSignsAdd = { fg = zephyr.dark_green },
    GitSignsChange = { fg = zephyr.blue },
    GitSignsDelete = { fg = zephyr.red },
    GitSignsAddNr = { fg = zephyr.dark_green },
    GitSignsChangeNr = { fg = zephyr.blue },
    GitSignsDeleteNr = { fg = zephyr.red },
    GitSignsAddLn = { bg = zephyr.bg_popup },
    GitSignsChangeLn = { bg = zephyr.bg_highlight },
    GitSignsDeleteLn = { bg = zephyr.bg1 },

    SignifySignAdd = { fg = zephyr.dark_green },
    SignifySignChange = { fg = zephyr.blue },
    SignifySignDelete = { fg = zephyr.red },

    dbui_tables = { fg = zephyr.blue },

    DiagnosticError = { fg = zephyr.pale_red },
    DiagnosticWarning = { fg = zephyr.dark_orange },
    DiagnosticInfo = { fg = zephyr.blue },
    DiagnosticHint = { fg = zephyr.teal },

    LspDiagnosticsError = { fg = zephyr.pale_red },
    LspDiagnosticsWarning = { fg = zephyr.dark_orange },
    LspDiagnosticsInformation = { fg = zephyr.blue },
    LspDiagnosticsHint = { fg = zephyr.teal },

    DiagnosticsSignErrorLine = { fg = zephyr.pale_red },
    DiagnosticsSignWarnLine = { fg = zephyr.dark_orange },
    DiagnosticsSignInfoLine = { fg = zephyr.blue },
    DiagnosticsSignHintLine = { fg = zephyr.teal },

    LspDiagnosticsSignErrorLine = { fg = zephyr.pale_red },
    LspDiagnosticsSignWarningLine = { fg = zephyr.dark_orange },
    LspDiagnosticsSignInformationLine = { fg = zephyr.blue },
    LspDiagnosticsSignHintLine = { fg = zephyr.teal },

    DiagnosticSignError = { fg = zephyr.pale_red },
    DiagnosticSignWarn = { fg = zephyr.dark_orange },
    DiagnosticSignInfo = { fg = zephyr.blue },
    DiagnosticSignHint = { fg = zephyr.teal },

    LspDiagnosticsSignError = { fg = zephyr.pale_red },
    LspDiagnosticsSignWarning = { fg = zephyr.dark_orange },
    LspDiagnosticsSignInformation = { fg = zephyr.blue },
    LspDiagnosticsSignHint = { fg = zephyr.teal },

    DiagnosticFloatingError = { fg = zephyr.pale_red },
    DiagnosticFloatingWarn = { fg = zephyr.dark_orange },
    DiagnosticFloatingInfo = { fg = zephyr.blue },
    DiagnosticFloatingHint = { fg = zephyr.teal },

    LspDiagnosticsFloatingError = { fg = zephyr.pale_red },
    LspDiagnosticsFloatingWarning = { fg = zephyr.dark_orange },
    LspDiagnosticsFloatingInformation = { fg = zephyr.blue },
    LspDiagnosticsFloatingHint = { fg = zephyr.teal },

    DiagnosticUnderlineError = { style = "undercurl", sp = zephyr.pale_red },
    DiagnosticUnderlineWarn = { style = "undercurl", sp = zephyr.dark_orange },
    DiagnosticUnderlineInfo = { style = "undercurl", sp = zephyr.blue },
    DiagnosticUnderlineHint = { style = "undercurl", sp = zephyr.teal },

    LspDiagnosticsUnderlineError = { style = "undercurl", sp = zephyr.pale_red },
    LspDiagnosticsUnderlineWarning = { style = "undercurl", sp = zephyr.dark_orange },
    LspDiagnosticsUnderlineInformation = { style = "undercurl", sp = zephyr.blue },
    LspDiagnosticsUnderlineHint = { style = "undercurl", sp = zephyr.teal },

    LspDiagnosticsVirtualTextError = { fg = zephyr.pale_red },
    LspDiagnosticsVirtualTextWarning = { fg = zephyr.dark_orange },
    LspDiagnosticsVirtualTextInformation = { fg = zephyr.blue },
    LspDiagnosticsVirtualTextHint = { fg = zephyr.teal },

    LspDiagnosticsDefaultError = { fg = zephyr.pale_red },
    LspDiagnosticsDefaultWarning = { fg = zephyr.dark_orange },
    LspDiagnosticsDefaultInformation = { fg = zephyr.blue },
    LspDiagnosticsDefaultHint = { fg = zephyr.teal },

    LspReferenceRead = { bg = zephyr.base4 },
    LspReferenceText = { bg = zephyr.base4 },
    LspReferenceWrite = { bg = zephyr.base4 },

    TroubleCount = { bg = zephyr.bg_highlight2, fg = zephyr.magenta },
    TroubleFile = { fg = zephyr.blue, style = "bold" },
    TroubleTextError = { fg = zephyr.red },
    TroubleTextWarning = { fg = zephyr.yellow },
    TroubleTextInformation = { fg = zephyr.blue },
    TroubleTextHint = { fg = zephyr.teal },

    BqfPreviewBorder = { fg = zephyr.blue },
    BqfSign = { fg = zephyr.red },
    BqfPreviewRange = "fg = zephyr.red",

    CursorWord0 = { bg = zephyr.cursor_bg },
    CursorWord1 = { bg = zephyr.none },
    CursorWord = { bg = zephyr.none },

    NvimTreeFolderName = { fg = zephyr.blue },
    NvimTreeRootFolder = { fg = zephyr.base5, style = "bold" },
    NvimTreeEmptyFolderName = { fg = zephyr.base5 },
    NvimTreeSpecialFile = { fg = zephyr.fg, bg = zephyr.none, style = "NONE" },
    NvimTreeOpenedFolderName = { fg = zephyr.base5 },

    TelescopeNormal = { fg = zephyr.fg },
    TelescopeBorder = { fg = zephyr.blue2, bg = zephyr.bg },
    TelescopeResultsBorder = { fg = zephyr.blue2, bg = zephyr.bg },
    TelescopePromptBorder = { fg = zephyr.blue2, bg = zephyr.bg },
    TelescopePreviewBorder = { fg = zephyr.magenta, bg = zephyr.bg },
    TelescopeMatching = { fg = zephyr.yellowgreen, style = "bold" },
    TelescopeSelection = { fg = zephyr.cyan, style = "bold" },
    TelescopeSelectionCaret = { fg = zephyr.yellow },
    TelescopeMultiSelection = { fg = zephyr.light_green },
    TelescopePromptPrefix = { fg = zephyr.yellow },

    FloatermBorder = { fg = zephyr.blue2, bg = zephyr.bg },

    DashboardShortCut = { fg = zephyr.blue4 },
    DashboardHeader = { fg = zephyr.blue2 },
    DashboardCenter = { fg = zephyr.blue2 },
    DashboardFooter = { fg = zephyr.cyan2, style = "bold" },

    WhichKey = { fg = zephyr.blue2 },
    WhichKeyName = { fg = zephyr.pink },
    WhichKeyTrigger = { fg = zephyr.black },
    WhichKeyFloating = { fg = zephyr.red },
    WhichKeySeperator = { fg = zephyr.blue3 },
    WhichKeyGroup = { fg = zephyr.blue2 },
    WhichKeyDesc = { fg = zephyr.blue3 },
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
  vim.g.colors_name = "zephyr"
  local syntax = zephyr.load_syntax()
  for group, colors in pairs(syntax) do
    zephyr.highlight(group, colors)
  end
  async_load_plugin:send()
end

zephyr.colorscheme()

return zephyr
