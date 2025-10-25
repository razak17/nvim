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
    { StatusColSep = { link = 'Dim' } },
    { StatusColFold = { link = 'Comment' } },
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
    -- builtin colorschemes
    ['default'] = {
      {
        NormalFloat = {
          bg = { from = 'Normal', alter = -0.1 },
          fg = { from = 'Normal' },
        },
      },
      {
        StatusLine = {
          bg = { from = 'StatusLine', alter = -0.85 },
          fg = { from = 'Normal' },
        },
      },
      {
        VertSplit = {
          bg = 'NONE',
          fg = { from = 'NonText', alter = -0.2 },
        },
      },
      { WinSeparator = { link = 'VertSplit' } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      { Comment = { fg = { from = 'Comment', alter = -0.2 } } },
      { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.3 } } },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
        },
      },
      { CurSearch = { link = 'WildMenu' } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.2 } } },
      { Winbar = { link = 'Variable' } },
      { WinbarNC = { link = 'LineNr' } },
      { Pmenu = { link = 'NormalFloat' } },
      { PmenuBorder = { link = 'FloatBorder' } },
      { PmenuExtra = { link = 'Pmenu' } },
      { PmenuSel = { bg = { from = 'Search' }, reverse = false } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuThumb = { link = 'CurSearch' } },
    },
    ['habamax'] = {
      { Normal = { bg = { from = 'Normal', alter = -0.15 } } },
      { NormalFloat = { bg = { from = 'Normal', alter = -0.1 } } },
      { LspReferenceRead = { link = 'CursorLine' } },
      {
        FloatTitle = {
          bg = { from = 'CursorLine' },
          fg = { from = 'Normal' },
        },
      },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'DiagnosticVirtualTextInfo' },
          italic = true,
        },
      },
      {
        Visual = {
          bg = { from = 'Visual', alter = 0.5 },
          reverse = false,
        },
      },
      {
        VertSplit = {
          bg = { from = 'Normal' },
          fg = { from = 'NonText', alter = -0.2 },
        },
      },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
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
    },
    ['peachpuff'] = {
      { NormalFloat = { link = 'Normal' } },
      {
        FloatTitle = {
          bg = { from = 'CursorLine' },
          fg = { from = 'NormalFloat' },
        },
      },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
        },
      },
      {
        VertSplit = {
          fg = { from = 'LineNr', alter = 0.5 },
          bg = { from = 'Normal' },
        },
      },
      { WinSeparator = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'WinSeparator' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      {
        FloatBorder = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'VertSplit' },
        },
      },
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
      { ColorColumn = { bg = { from = 'CursorLine', alter = 0.1 } } },
      { FloatTitle = { bg = { from = 'NormalFloat' } } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
      { CursorLine = { link = 'CursorLine' } },
      { NonText = { fg = { from = 'NonText', alter = 0.4 } } },
      { LspReferenceRead = { link = 'CursorLine' } },
      { StatusLine = { bg = 'NONE', reverse = false } },
      {
        Visual = {
          bg = { from = 'CursorLine', alter = 0.2 },
          fg = 'NONE',
        },
      },
      {
        FloatBorder = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'NormalFloat', attr = 'bg' },
        },
      },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
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
      { IndentBlanklineChar = { link = 'NonText' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
    },
    ['slate'] = {
      { NormalFloat = { bg = { from = 'Normal' } } },
      { Visual = { link = 'CursorLine' } },
      { StatusLine = { bg = 'NONE' } },
      {
        VertSplit = {
          bg = 'NONE',
          fg = { from = 'Comment', alter = -0.3 },
        },
      },
      { FloatBorder = { link = 'VertSplit' } },
      { FloatTitle = { bg = { from = 'CursorLine', alter = 0.05 } } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'DiagnosticVirtualTextInfo' },
          italic = true,
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
      { PmenuKind = { fg = { from = 'Comment', alter = -0.1 } } },
      { PmenuMatch = { link = 'Normal' } },
      { PmenuSel = { link = 'CursorLine' } },
      { PmenuExtraSel = { link = 'PmenuSel' } },
      { PmenuKindSel = { link = 'PmenuSel' } },
      { PmenuMatchSel = { link = 'PmenuSel' } },
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
        FloatTitle = {
          bg = { from = 'CursorLine' },
          fg = { from = 'FloatTitle', alter = 0.5 },
        },
      },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
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
      { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
      { LineNr = { fg = { from = 'Comment' } } },
      { NonText = { fg = { from = 'Comment' } } },
      { VertSplit = { fg = { from = 'NonText', alter = -0.2 } } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      { WinSeparator = { link = 'VertSplit' } },
      { Visual = { link = 'CursorLine' } },
      { Search = { bg = { from = 'Search', alter = -0.2 } } },
      { IncSearch = { link = 'Search' } },
      { StatusLine = { inherit = 'Normal' } },
    },
    ['wildcharm'] = {
      { NormalFloat = { bg = { from = 'Normal', alter = 0.3 } } },
      { StatusLine = { bg = 'NONE', reverse = false } },
      { Visual = { link = 'CursorLine' } },
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
        FloatTitle = {
          bg = { from = 'CursorLine', alter = 0.05 },
          fg = { from = 'Normal' },
        },
      },
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'DiagnosticVirtualTextInfo' },
          italic = true,
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

local scheme_switcher = require('ar.scheme_switcher')
ar.load_colorscheme(scheme_switcher.get_current_colorscheme())
