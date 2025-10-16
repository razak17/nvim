local enabled = ar_config.plugin.main.colors.enable

if not ar or ar.none or not enabled then return end

local highlight = ar.highlight
local transparent = ar_config.ui.transparent.enable

local function general_overrides()
  highlight.all({
    { CursorLineNr = { bg = 'NONE' } },
    { mkdLineBreak = { clear = true } },
    { LineNr = { bg = 'NONE' } },
    { ErrorMsg = { bg = 'NONE' } },
    { Cursor = { fg = 'NONE' } },
    { UnderlinedTitle = { bold = true, underline = true } },
    { Strict = { link = 'DiffDelete' } },
    ----------------------------------------------------------------------------
    -- colorscheme overrides
    ----------------------------------------------------------------------------
    { QuickFixLine = { bg = { from = 'CursorLine' }, fg = 'NONE' } },
    -- Neither the sign column or end of buffer highlights require an explicit bg
    -- they should both just use the bg that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { bg = 'NONE' } },
    { EndOfBuffer = { bg = 'NONE' } },
    { GitSignsCurrentLineBlame = { link = 'Comment' } },
    { StatusColSep = { link = 'Comment' } },
    ----------------------------------------------------------------------------
    --  Semantic tokens
    ----------------------------------------------------------------------------
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.type.variable'] = { link = '@variable' } },
    { ['@lsp.typemod.method'] = { link = '@method' } },
    {
      ['@lsp.typemod.variable.global'] = {
        bold = true,
        inherit = '@constant.builtin',
      },
    },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.type.type.lua'] = { clear = true } },
    { ['@lsp.typemod.number.injected'] = { link = '@number' } },
    { ['@lsp.typemod.operator.injected'] = { link = '@operator' } },
    { ['@lsp.typemod.keyword.injected'] = { link = '@keyword' } },
    { ['@lsp.typemod.string.injected'] = { link = '@string' } },
    { ['@lsp.typemod.variable.injected'] = { link = '@variable' } },
    ----------------------------------------------------------------------------
    -- Treesitter
    ----------------------------------------------------------------------------
    { ['@keyword.return'] = { italic = true, fg = { from = 'Keyword' } } },
    { ['@type.qualifier'] = { inherit = '@keyword', italic = true } },
    { ['@parameter'] = { italic = true, bold = true, fg = 'NONE' } },
    { ['@text.diff.add'] = { link = 'DiffAdd' } },
    { ['@text.diff.delete'] = { link = 'DiffDelete' } },
    { ['@text.title.markdown'] = { underdouble = true } },
    {
      ['@text.literal.markdown'] = {
        bg = transparent and 'NONE' or { from = 'Normal', alter = 0.15 },
      },
    },
    ----------------------------------------------------------------------------
    -- LSP
    ----------------------------------------------------------------------------
    { LspInlayHint = { inherit = 'Comment', italic = true } },
    { LspCodeLens = { inherit = 'Comment', bold = true, italic = false } },
    { LspCodeLensSeparator = { bold = false, italic = false } },
    {
      LspReferenceText = {
        bg = 'NONE',
        underline = true,
        sp = { from = 'Directory', attr = 'fg', alter = -0.6 },
      },
    },
    {
      LspReferenceRead = {
        bg = { from = 'CursorLine', attr = 'bg', alter = 0.2 },
      },
    },
    { LspReferenceWrite = { inherit = 'LspReferenceText', bold = false } },
    { LspReferenceTarget = { inherit = 'Dim', bold = true } },
    { LspSignatureActiveParameter = { link = 'Visual' } },
    { DiagnosticFloatTitle = { inherit = 'FloatTitle', bold = true } },
    {
      DiagnosticFloatTitleIcon = {
        inherit = 'FloatTitle',
        fg = { from = '@character' },
      },
    },
    { ['@illuminate'] = { link = 'LspReferenceText' } },
    { DevIconDefault = { link = 'Comment' } },
    { NotifyBackground = { link = 'NormalFloat' } },
    { statusLine = { bg = 'NONE' } },
  })
end

local function set_sidebar_highlight()
  highlight.all({
    {
      PanelDarkBackground = {
        bg = transparent and 'NONE' or { from = 'Normal', alter = -0.53 },
      },
    },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    {
      PanelBackground = {
        bg = transparent and 'NONE' or { from = 'Normal', alter = -0.13 },
      },
    },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    {
      PanelVertSplit = {
        inherit = 'PanelBackground',
        fg = { from = 'WinSeparator' },
      },
    },
    {
      PanelVertSplitAlt = {
        inherit = 'PanelBackground',
        fg = { from = 'WinSeparator' },
      },
    },
    {
      PanelWinSeparator = {
        inherit = 'PanelBackground',
        fg = { from = 'WinSeparator' },
      },
    },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { bg = { from = 'Visual', alter = -0.1 } } },
  })
end

local sidebar_fts = {
  'flutterToolsOutline',
  'undotree',
  'NvimTree',
  'neo-tree',
  'qf',
  'neotest-summary',
}

local function on_sidebar_enter()
  vim.opt_local.winhighlight:append({
    Normal = 'PanelBackground',
    EndOfBuffer = 'PanelBackground',
    StatusLine = 'PanelSt',
    StatusLineNC = 'PanelStNC',
    SignColumn = 'PanelBackground',
    VertSplit = 'PanelVertSplit',
    WinSeparator = 'PanelWinSeparator',
  })
end

local function colorscheme_overrides()
  local overrides = {
    ['onedark'] = {
      { Dim = { inherit = 'VertSplit' } },
      { NeorgContext = { inherit = 'Normal' } },
      -- { ['@variable'] = { fg = { from = '@none' } } },
      { dmapWin = { inherit = 'Normal' } },
      { Strict = { link = 'DiffDeleteAlt' } },
      { Pmenu = { link = 'NormalFloat' } },
      { PmenuBorder = { link = 'FloatBorder' } },
    },
    ['default'] = {
      {
        NormalFloat = {
          bg = { from = 'Normal', alter = -0.1 },
          fg = { from = 'Normal' },
        },
      },
      { Comment = { fg = { from = 'Comment', alter = -0.2 } } },
      { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.3 } } },
      {
        StatusLine = {
          bg = { from = 'StatusLine', alter = -0.85 },
          fg = { from = 'Normal' },
        },
      },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      { IndentBlanklineContextChar = { link = 'Comment' } },
      { Pmenu = { link = 'NormalFloat' } },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuSel = { bg = { from = 'Search' }, reverse = false } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuThumb = { link = 'CurSearch' } },
      { VertSplit = { fg = { from = 'NonText', alter = -0.2 } } },
      { CurSearch = { link = 'WildMenu' } },
      { WinSeparator = { link = 'VertSplit' } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { Winbar = { link = 'Variable' } },
      { WinbarNC = { link = 'LineNr' } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.2 } } },
      {
        SnacksPickerToggleHidden = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
        },
      },
      { SnacksPickerToggleIgnored = { link = 'SnacksPickerToggleHidden' } },
    },
    ['vim'] = {
      { Normal = { bg = '#24283b' } },
      { NormalFloat = { link = 'Normal' } },
      { StatusLine = { inherit = 'NormalFloat' } },
      { Conceal = { bg = { from = 'NormalFloat' } } },
      { CursorLine = { bg = { from = 'CursorLine', alter = -0.5 } } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.15 } } },
      { LspReferenceRead = { bg = { from = 'CursorLine', alter = 0.1 } } },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Comment', alter = 0.2 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuKind = { link = 'Comment' } },
      { PmenuMatch = { link = 'NormalFloat' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
      { LineNr = { fg = { from = 'Comment' } } },
      { NonText = { fg = { from = 'Comment' } } },
      { VertSplit = { fg = { from = 'NonText', alter = -0.2 } } },
      { WinSeparator = { link = 'VertSplit' } },
      { Visual = { link = 'CursorLine' } },
      { Search = { bg = { from = 'Search', alter = -0.2 } } },
      { FloatTitle = { link = 'CursorLine' } },
      { IncSearch = { link = 'Search' } },
      { StatusLine = { inherit = 'Normal' } },
      { FloatBorder = { fg = { from = 'NonText', alter = -0.2 } } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
    },
    ['habamax'] = {
      { Normal = { bg = { from = 'Normal', alter = -0.15 } } },
      { NormalFloat = { bg = { from = 'Normal', alter = -0.1 } } },
      { FloatTitle = { bg = { from = 'NormalFloat', alter = -0.05 } } },
      {
        VertSplit = {
          bg = { from = 'Normal' },
          fg = { from = 'NonText', alter = -0.2 },
        },
      },
      { Visual = { bg = { from = 'Search', alter = -0.3 } } },
      { LspReferenceRead = { link = 'CursorLine' } },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Comment', alter = 0.2 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      {
        PmenuKind = {
          bg = 'NONE',
          fg = { from = 'Comment', alter = -0.3 },
        },
      },
      {
        PmenuMatch = {
          bg = 'NONE',
          fg = { from = 'Normal', alter = 0.4 },
        },
      },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'NonText' } },
    },
    ['peachpuff'] = {
      { NormalFloat = { link = 'Normal' } },
      {
        VertSplit = {
          fg = { from = 'LineNr', alter = 0.5 },
          bg = { from = 'Normal' },
        },
      },
      { WinSeparator = { link = 'VertSplit' } },
      {
        FloatBorder = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'VertSplit' },
        },
      },
      { FloatTitle = { link = 'CursorLine' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
      {
        LspReferenceRead = {
          bg = { from = 'CursorLine', attr = 'bg', alter = -0.1 },
        },
      },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Comment', alter = 0.2 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuKind = { link = 'Comment' } },
      { PmenuMatch = { link = 'NormalFloat' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { StatusLine = { bg = 'NONE' } },
    },
    ['retrobox'] = {
      { NormalFloat = { bg = { from = 'NormalFloat', alter = -0.35 } } },
      {
        FloatBorder = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'NormalFloat', attr = 'bg' },
        },
      },
      { FloatTitle = { bg = { from = 'NormalFloat' } } },
      { LspReferenceRead = { link = 'CursorLine' } },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Comment', alter = 0.2 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuKind = { link = 'Comment' } },
      { PmenuMatch = { link = 'NormalFloat' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { IndentBlanklineChar = { link = 'NonText' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      {
        SnacksPickerCursorLine = {
          bg = { from = 'CursorLine', alter = 0.2 },
        },
      },
      { SnacksPickerListCursorLine = { link = 'SnacksPickerCursorLine' } },
      { SnacksPickerDir = { link = 'Comment' } },
      { SnacksPickerTotals = { link = 'Debug' } },
      { SnacksPickerTitle = { link = 'FloatTitle' } },
      {
        SnacksPickerToggleHidden = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Special' },
        },
      },
      {
        SnacksPickerToggleIgnored = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Debug' },
        },
      },
      { StatusLine = { bg = 'NONE', reverse = false } },
    },
    ['slate'] = {
      { NormalFloat = { bg = { from = 'Normal' } } },
      {
        VertSplit = {
          fg = { from = 'Comment', alter = -0.3 },
          bg = { from = 'Normal' },
        },
      },
      { FloatBorder = { link = 'VertSplit' } },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Normal', alter = -0.25 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuKind = { fg = { from = 'Comment', alter = -0.1 } } },
      { PmenuMatch = { link = 'Normal' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { SnacksPickerTitle = { link = 'FloatTitle' } },
      {
        SnacksPickerCursorLine = {
          bg = { from = 'CursorLine', alter = 0.2 },
        },
      },
      { SnacksPickerListCursorLine = { link = 'SnacksPickerCursorLine' } },
      {
        SnacksPickerToggleHidden = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Special' },
        },
      },
      {
        SnacksPickerToggleIgnored = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Debug' },
        },
      },
      { StatusLine = { bg = 'NONE' } },
    },
    ['wildcharm'] = {
      { NormalFloat = { bg = { from = 'Normal', alter = 0.3 } } },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      { VertSplit = { fg = { from = 'VertSplit', alter = -0.3 } } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      {
        LspReferenceText = {
          bg = 'NONE',
          underline = true,
          reverse = false,
          sp = { from = 'Directory', attr = 'fg', alter = -0.6 },
        },
      },
      {
        LspReferenceRead = {
          bg = { from = 'CursorLine', alter = 0.1 },
          reverse = false,
        },
      },
      {
        LspReferenceWrite = {
          inherit = 'LspReferenceText',
          bold = false,
          reverse = false,
        },
      },
      {
        Pmenu = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'Normal', alter = -0.25 },
        },
      },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuKind = { link = 'Dim' } },
      { PmenuMatch = { link = 'Normal' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
      { SnacksPickerCursorLine = { bg = { from = 'Folded' } } },
      { SnacksPickerListCursorLine = { link = 'SnacksPickerCursorLine' } },
      { SnacksPickerToggleHidden = { bg = { from = 'FloatTitle' } } },
      { SnacksPickerToggleIgnored = { bg = { from = 'FloatTitle' } } },
      { StatusLine = { bg = 'NONE', reverse = false } },
    },
    ['vague'] = {
      { VertSplit = { fg = { from = 'Comment', alter = -0.4 } } },
      { WinSeparator = { link = 'VertSplit' } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
      { StatusLine = { bg = 'NONE' } },
    },
    ['conifer'] = {
      { VertSplit = { bg = { from = 'Normal' }, fg = { from = 'LineNr' } } },
      { WinSeparator = { link = 'VertSplit' } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'LineNr' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
      { PmenuBorder = { link = 'NormalFloat' } },
    },
    ['kanso'] = {
      { FloatBorder = { link = 'VertSplit' } },
      { PmenuBorder = { link = 'NormalFloat' } },
    },
    ['nanode'] = {
      { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
      { CursorLine = { bg = { from = 'CursorLine', alter = 0.8 } } },
      { LineNr = { fg = { from = 'LineNr', alter = -0.3 } } },
      { CursorLineNr = { link = 'String' } },
      { Visual = { bg = { from = 'Visual', alter = -0.5 }, fg = 'NONE' } },
      { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
      { Dim = { fg = { from = 'Comment', alter = -0.3 } } },
      { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.2 } } },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      { FloatBorder = { link = 'Dim' } },
      { TelescopeBorder = { link = 'FloatBorder' } },
      { TelescopePromptBorder = { link = 'FloatBorder' } },
      { TelescopePreviewBorder = { link = 'FloatBorder' } },
      { TelescopeResultsBorder = { link = 'FloatBorder' } },
      { Winbar = { link = 'Variable' } },
      { PmenuBorder = { link = 'NormalFloat' } },
      { IndentBlanklineChar = { link = 'Dim' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      { SnacksPickerCursorLine = { bg = { from = 'Folded' } } },
      { SnacksPickerListCursorLine = { link = 'SnacksPickerCursorLine' } },
      { TelescopeSelection = { bg = { from = 'Folded' } } },
      { TelescopePromptTitle = { link = 'FloatTitle' } },
      { TelescopePreviewTitle = { link = 'FloatTitle' } },
      { TelescopeResultsTitle = { link = 'FloatTitle' } },
    },
    ['lunar'] = {
      { VertSplit = { fg = { from = 'Comment', alter = -0.4 } } },
      { WinSeparator = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
      { Pmenu = { link = 'NormalFloat' } },
      { PmenuBorder = { link = 'FloatBorder' } },
      { NeogitDiffAdd = { link = 'DiffAdd' } },
      { NeogitDiffDelete = { link = 'DiffDelete' } },
      { ColorColumn = { link = 'CursorLine' } },
      { Todo = { link = 'Constant' } },
      { Winbar = { link = 'Variable' } },
      { WinbarNC = { link = 'LineNr' } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if hls then highlight.all(hls) end
end

local function user_highlights()
  general_overrides()
  colorscheme_overrides()
  if not transparent then set_sidebar_highlight() end
end

ar.augroup('UserHighlights', {
  event = { 'ColorScheme' },
  command = function() user_highlights() end,
}, {
  event = { 'FileType' },
  pattern = sidebar_fts,
  command = function()
    if not transparent then on_sidebar_enter() end
  end,
})

if ar.plugins.niceties then
  local scheme_switcher = require('ar.scheme_switcher')
  ar.load_colorscheme(scheme_switcher.get_current_colorscheme())
else
  ar.load_colorscheme(ar_config.colorscheme)
end
