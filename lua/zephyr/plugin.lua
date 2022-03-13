local P = rvim.palette
local util = require "zephyr.util"

return {
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
  diffBDiffer = { link = "WarningMsg", force = true },
  diffCommon = { link = "WarningMsg", force = true },
  diffDiffer = { link = "WarningMsg", force = true },
  diffIdentical = { link = "WarningMsg", force = true },
  diffIsA = { link = "WarningMsg", force = true },
  diffNoEOL = { link = "WarningMsg", force = true },
  diffOnly = { link = "WarningMsg", force = true },

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

  DiagnosticError = { fg = P.error_red },
  DiagnosticWarning = { fg = P.dark_orange },
  DiagnosticInfo = { fg = P.blue },
  DiagnosticHint = { fg = P.teal },

  LspDiagnosticsError = { fg = P.error_red },
  LspDiagnosticsWarning = { fg = P.dark_orange },
  LspDiagnosticsInformation = { fg = P.blue },
  LspDiagnosticsHint = { fg = P.dark_green },

  DiagnosticsSignErrorLine = { fg = P.error_red },
  DiagnosticsSignWarnLine = { fg = P.dark_orange },
  DiagnosticsSignInfoLine = { fg = P.blue },
  DiagnosticsSignHintLine = { fg = P.dark_green },

  DiagnosticSignError = { fg = P.error_red },
  DiagnosticSignWarn = { fg = P.dark_orange },
  DiagnosticSignInfo = { fg = P.blue },
  DiagnosticSignHint = { fg = P.dark_green },

  DiagnosticFloatingError = { fg = P.error_red },
  DiagnosticFloatingWarn = { fg = P.dark_orange },
  DiagnosticFloatingInfo = { fg = P.blue },
  DiagnosticFloatingHint = { fg = P.dark_green },

  LspDiagnosticsFloatingError = { fg = P.error_red },
  LspDiagnosticsFloatingWarning = { fg = P.dark_orange },
  LspDiagnosticsFloatingInformation = { fg = P.blue },
  LspDiagnosticsFloatingHint = { fg = P.dark_green },

  DiagnosticUnderlineError = { style = "undercurl", sp = P.error_red },
  DiagnosticUnderlineWarn = { style = "undercurl", sp = P.dark_orange },
  DiagnosticUnderlineInfo = { style = "undercurl", sp = P.blue },
  DiagnosticUnderlineHint = { style = "undercurl", sp = P.dark_green },

  LspDiagnosticsVirtualTextError = { fg = P.error_red },
  LspDiagnosticsVirtualTextWarning = { fg = P.dark_orange },
  LspDiagnosticsVirtualTextInformation = { fg = P.blue },
  LspDiagnosticsVirtualTextHint = { fg = P.dark_green },

  DiagnosticVirtualTextError = { fg = P.error_red, bg = util.alter_color(P.pale_red, -80) },
  DiagnosticVirtualTextWarn = { fg = P.dark_orange, bg = util.alter_color(P.dark_orange, -80) },
  DiagnosticVirtualTextInfo = { fg = P.pale_blue, bg = util.alter_color(P.pale_blue, -80) },
  DiagnosticVirtualTextHint = { fg = P.dark_green, bg = util.alter_color(P.dark_green, -80) },

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

  NvimTreeFolderIcon = { fg = P.blue },
  NvimTreeIndentMarker = { fg = P.base6 },
  -- NvimTreeVertSplit = { fg = P.blue, bg = P.red },
  -- NvimTreeNormal = { bg = P.alt_bg },
  NvimTreeFolderName = { fg = P.blue },
  NvimTreeOpenedFolderName = { fg = P.base5 },
  NvimTreeImageFile = { fg = P.purple },
  NvimTreeSpecialFile = { fg = P.orange },

  NvimTreeGitStaged = { fg = P.dark_green },
  NvimTreeCursorLine = { bg = P.red },
  NvimTreeGitNew = { fg = P.sign_add },
  NvimTreeGitDirty = { fg = P.dark_green },
  NvimTreeGitDeleted = { fg = P.sign_delete },
  NvimTreeGitMerge = { fg = P.sign_change },
  NvimTreeGitRenamed = { fg = P.sign_change },

  NvimTreeLspDiagnosticsError = { fg = P.error_red },
  NvimTreeLspDiagnosticsWarning = { fg = P.dark_orange },
  NvimTreeLspDiagnosticsInformati = { fg = P.blue },
  NvimTreeLspDiagnosticsHint = { fg = P.dark_green },

  NvimTreeSymlink = { fg = P.cyan },
  NvimTreeExecFile = { fg = P.green },
  NvimTreeEmptyFolderName = { fg = P.base5 },

  TelescopeNormal = { fg = P.fg },
  TelescopeBorder = { fg = P.blue, bg = P.darker_bg },
  TelescopeResultsBorder = { fg = P.blue, bg = P.darker_bg },
  TelescopePromptBorder = { fg = P.blue, bg = P.darker_bg },
  TelescopePreviewBorder = { fg = P.magenta, bg = P.darker_bg },
  TelescopeMatching = { fg = P.yellowgreen, style = "bold" },
  TelescopeSelection = { fg = P.cyan, style = "bold" },
  TelescopeSelectionCaret = { fg = P.yellow },
  TelescopeMultiSelection = { fg = P.light_green },
  TelescopePromptPrefix = { fg = P.yellow },

  FloatermBorder = { fg = P.blue, bg = P.bg },

  DashboardShortCut = { fg = P.darker_blue },
  DashboardHeader = { fg = P.blue },
  DashboardCenter = { fg = P.blue },
  DashboardFooter = { fg = P.dark_cyan, style = "bold" },

  WhichKey = { fg = P.pink },
  WhichKeyName = { fg = P.yellow },
  WhichKeyTrigger = { fg = P.black },
  WhichKeyFloat = { fg = P.red, bg = P.darker_bg },
  WhichKeySeperator = { fg = P.yellowgreen },
  WhichKeyGroup = { fg = P.pale_blue },
  WhichKeyDesc = { fg = P.dark_cyan },

  NotifyERRORBorder = { fg = P.error_red },
  NotifyWARNBorder = { fg = P.dark_orange },
  NotifyINFOBorder = { fg = P.blue },
  NotifyDEBUGBorder = { fg = P.purple_test },
  NotifyTRACEBorder = { fg = P.purple },
  NotifyERRORIcon = { fg = P.error_red },
  NotifyWARNIcon = { fg = P.dark_orange },
  NotifyINFOIcon = { fg = P.blue },
  NotifyDEBUGIcon = { fg = P.purple_test },
  NotifyTRACEIcon = { fg = P.purple },
  NotifyERRORTitle = { fg = P.error_red },
  NotifyWARNTitle = { fg = P.dark_orange },
  NotifyINFOTitle = { fg = P.blue },
  NotifyDEBUGTitle = { fg = P.purple_test },
  NotifyTRACETitle = { fg = P.purple },
  NotifyERRORBody = { fg = P.fg },
  NotifyWARNBody = { fg = P.fg },
  NotifyINFOBody = { fg = P.fg },
  NotifyDEBUGBody = { fg = P.fg },
  NotifyTRACEBody = { fg = P.fg },
}
