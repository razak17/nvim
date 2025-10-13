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
    { statusline = { bg = 'NONE' } },
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
      { Pmenu = { bg = { from = 'Pmenu', alter = -0.2 } } },
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
    ['onedark'] = {
      { Dim = { inherit = 'VertSplit' } },
      { NeorgContext = { inherit = 'Normal' } },
      -- { ['@variable'] = { fg = { from = '@none' } } },
      { dmapWin = { inherit = 'Normal' } },
      { Strict = { link = 'DiffDeleteAlt' } },
    },
    ['vim'] = {
      { Normal = { bg = '#24283b' } },
      { NormalFloat = { bg = { from = 'Normal', alter = 0.15 } } },
      { StatusLine = { inherit = 'NormalFloat' } },
      { Conceal = { bg = { from = 'NormalFloat' } } },
      { CursorLine = { bg = { from = 'CursorLine', alter = -0.5 } } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.15 } } },
      { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
      { LineNr = { fg = { from = 'Comment' } } },
      { NonText = { fg = { from = 'Comment' } } },
      {
        VertSplit = {
          fg = { from = 'NonText', alter = -0.2 },
          bg = { from = 'Normal' },
        },
      },
      { WinSeparator = { link = 'VertSplit' } },
      {
        FloatBorder = {
          fg = { from = 'NonText', alter = -0.2 },
          bg = { from = 'NormalFloat' },
        },
      },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
    },
    ['habamax'] = {
      { Normal = { bg = { from = 'Normal', alter = -0.15 } } },
      { NormalFloat = { bg = { from = 'Normal', alter = -0.1 } } },
      { FloatTitle = { bg = { from = 'NormalFloat', alter = -0.05 } } },
      { Visual = { bg = { from = 'Search', alter = -0.3 } } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'NonText' } },
      {
        VertSplit = {
          bg = { from = 'Normal' },
          fg = { from = 'NonText', alter = -0.2 },
        },
      },
    },
    ['vague'] = {
      { VertSplit = { fg = { from = 'Comment', alter = -0.4 } } },
      { WinSeparator = { link = 'VertSplit' } },
      { FloatBorder = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
      { Statusline = { bg = 'NONE' } },
    },
    ['lunar'] = {
      { VertSplit = { fg = { from = 'Comment', alter = -0.4 } } },
      { WinSeparator = { link = 'VertSplit' } },
      { IndentBlanklineChar = { link = 'VertSplit' } },
      { IndentBlanklineContextChar = { link = 'VertSplit' } },
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
  scheme_switcher.set_colorscheme(scheme_switcher.get_current_colorscheme())
else
  ar.load_colorscheme(ar_config.colorscheme)
end
