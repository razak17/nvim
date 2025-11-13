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
  local theming = require('ar.theming')
  local overrides = {
    -- builtin colorschemes
    ['default'] = theming.generate_overrides({
      { CurSearch = { link = 'WildMenu' } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.2 } } },
      { Comment = { fg = { from = 'Comment', alter = -0.2 } } },
      { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.3 } } },
      { Dim = { link = 'NonText' } },
      { WinSeparator = { bg = 'NONE', fg = { from = 'Dim', alter = -0.2 } } },
      {
        StatusLine = {
          bg = { from = 'Folded', alter = -0.2 },
          fg = { from = 'Normal' },
        },
      },
      { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg', alter = 1.4 } } },
      {
        DiagnosticUnderlineError = {
          cterm = { undercurl = true },
          sp = { from = 'DiagnosticError', attr = 'fg' },
          undercurl = true,
        },
      },
      {
        DiagnosticUnderlineWarn = {
          cterm = { undercurl = true },
          sp = { from = 'DiagnosticWarn', attr = 'fg' },
          undercurl = true,
        },
      },
      {
        DiagnosticUnderlineInfo = {
          cterm = { undercurl = true },
          sp = { from = 'DiagnosticInfo', attr = 'fg' },
          undercurl = true,
        },
      },
      {
        DiagnosticUnderlineHint = {
          cterm = { undercurl = true },
          sp = { from = 'DiagnosticHint', attr = 'fg' },
          undercurl = true,
        },
      },
    }),
    ['habamax'] = theming.generate_overrides({
      {
        Visual = {
          bg = { from = 'Visual', alter = 0.5 },
          reverse = false,
        },
      },
      { Dim = { link = 'NonText' } },
      { WinSeparator = { bg = 'NONE', fg = { from = 'Dim', alter = -0.2 } } },
    }),
    ['peachpuff'] = theming.generate_overrides({
      {
        DiagnosticVirtualTextInfo = {
          bg = { from = 'FloatTitle' },
          fg = { from = 'Directory' },
          italic = true,
        },
      },
      { Dim = { link = 'LineNr' } },
      { WinSeparator = { fg = { from = 'Dim', alter = 0.5 }, bg = 'NONE' } },
    }),
    ['retrobox'] = theming.generate_overrides({
      { ColorColumn = { bg = { from = 'CursorLine', alter = 0.1 } } },
      { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
      { CursorLine = { link = 'CursorLine' } },
      { NonText = { fg = { from = 'NonText', alter = 0.4 } } },
      { Visual = { bg = { from = 'CursorLine', alter = 0.2 }, fg = 'NONE' } },
      { WinSeparator = { fg = { from = 'VertSplit' }, bg = 'NONE' } },
    }),
    ['slate'] = theming.generate_overrides({
      { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
      { Dim = { link = 'Comment' } },
      { WinSeparator = { bg = 'NONE', fg = { from = 'Dim', alter = -0.3 } } },
    }),
    ['vim'] = theming.generate_overrides({
      { Normal = { bg = '#24283b' } },
      { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
      { Title = { fg = { from = 'Title', alter = 0.4 } } },
      { LineNr = { fg = { from = 'Comment' } } },
      { NonText = { fg = { from = 'Comment' } } },
      { StatusLine = { reverse = false } },
      { CursorLine = { bg = { from = 'CursorLine', alter = -0.5 } } },
      { Conceal = { bg = { from = 'CursorLine' } } },
      { Folded = { bg = { from = 'CursorLine', alter = 0.15 } } },
      { Visual = { fg = { from = 'CursorLine', alter = 0.1 } } },
      { Search = { bg = { from = 'Search', alter = -0.2 } } },
      { IncSearch = { link = 'Search' } },
      { WinSeparator = { fg = { from = 'NonText', alter = -0.2 } } },
    }),
    ['wildcharm'] = theming.generate_overrides({
      { StatusLine = { reverse = false } },
      { Visual = { link = 'CursorLine' } },
      { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.45 } } },
    }),
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
