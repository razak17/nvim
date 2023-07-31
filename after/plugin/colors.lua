if not rvim or rvim and rvim.none then return end

local highlight = rvim.highlight

local function general_overrides()
  highlight.all({
    { CursorLineNr = { bg = 'NONE' } },
    { mkdLineBreak = { clear = true } },
    { LineNr = { bg = 'NONE' } },
    { ErrorMsg = { bg = 'NONE' } },
    { Cursor = { fg = 'NONE' } },
    { UnderlinedTitle = { bold = true, underline = true } },
    ------------------------------------------------------------------------------------------------
    -- colorscheme overrides
    ------------------------------------------------------------------------------------------------
    { QuickFixLine = { bg = { from = 'Cursorline' }, fg = 'NONE' } },
    -- Neither the sign column or end of buffer highlights require an explicit bg
    -- they should both just use the bg that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { bg = 'NONE' } },
    { EndOfBuffer = { bg = 'NONE' } },
    { GitSignsCurrentLineBlame = { link = 'Comment' } },
    { StatusColSep = { link = 'Comment' } },
    ------------------------------------------------------------------------------------------------
    --  Semantic tokens
    ------------------------------------------------------------------------------------------------
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.type.variable'] = { link = '@variable' } },
    { ['@lsp.typemod.method'] = { link = '@method' } },
    { ['@lsp.typemod.variable.global'] = { bold = true, inherit = '@constant.builtin' } },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.type.type.lua'] = { clear = true } },
    { ['@lsp.typemod.number.injected'] = { link = '@number' } },
    { ['@lsp.typemod.operator.injected'] = { link = '@operator' } },
    { ['@lsp.typemod.keyword.injected'] = { link = '@keyword' } },
    { ['@lsp.typemod.string.injected'] = { link = '@string' } },
    { ['@lsp.typemod.variable.injected'] = { link = '@variable' } },
    ------------------------------------------------------------------------------------------------
    -- Treesitter
    ------------------------------------------------------------------------------------------------
    { ['@keyword.return'] = { italic = true, fg = { from = 'Keyword' } } },
    { ['@type.qualifier'] = { inherit = '@keyword', italic = true } },
    { ['@parameter'] = { italic = true, bold = true, fg = 'NONE' } },
    { ['@text.diff.add'] = { link = 'DiffAdd' } },
    { ['@text.diff.delete'] = { link = 'DiffDelete' } },
    { ['@text.title.markdown'] = { underdouble = true } },
    { ['@text.literal.markdown'] = { bg = { from = 'Normal', alter = 0.15 } } },
    ------------------------------------------------------------------------------------------------
    -- LSP
    ------------------------------------------------------------------------------------------------
    { LspCodeLens = { inherit = 'Comment', bold = true, italic = false } },
    { LspCodeLensSeparator = { bold = false, italic = false } },
    {
      LspReferenceText = {
        bg = 'NONE',
        underline = true,
        sp = { from = 'CursorLineNr', attr = 'fg', alter = -0.3 },
      },
    },
    { LspReferenceRead = { link = 'LspReferenceText' } },
    { LspReferenceWrite = { inherit = 'LspReferenceText', bold = true, underline = true } },
    { LspSignatureActiveParameter = { link = 'Visual' } },
    { DiagnosticFloatTitle = { inherit = 'FloatTitle', bold = true } },
    { DiagnosticFloatTitleIcon = { inherit = 'FloatTitle', fg = { from = '@character' } } },
    { ['@illuminate'] = { link = 'LspReferenceText' } },
  })
end

local function set_sidebar_highlight()
  highlight.all({
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.53 } } },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { bg = { from = 'Normal', alter = -0.08 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    { PanelVertSplit = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
    { PanelVertSplitAlt = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
    { PanelWinSeparator = { inherit = 'PanelBackground', fg = { from = 'WinSeparator' } } },
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
      { ['@variable'] = { fg = { from = '@none' } } },
      {
        Headline = {
          bold = true,
          italic = true,
          bg = { from = 'Normal', alter = 0.2 },
        },
      },
      { Headline1 = { bg = '#003c30' } },
      { Headline2 = { bg = '#00441b' } },
      { Headline3 = { bg = '#084081' } },
      { Dash = { bg = '#0b60a1', bold = true } },
      {
        CodeBlock = {
          bold = true,
          italic = true,
          bg = { from = 'CursorLine', alter = -0.35 },
        },
      },
      { CmpItemAbbr = { fg = { from = 'MsgSeparator' } } },
      { CmpItemAbbrDeprecated = { strikethrough = true, inherit = 'Comment' } },
      { CmpItemAbbrMatch = { fg = { from = 'Search' }, bold = true } },
      { CmpItemAbbrMatchFuzzy = { fg = { from = 'Search' } } },
      { CmpItemMenu = { fg = { from = 'Comment' }, italic = true, bold = true } },
      { NeogitDiffAdd = { inherit = 'DiffAdd' } },
      { NeogitDiffDelete = { inherit = 'DiffDelete' } },
      { NeogitHunkHeader = { inherit = 'Headline2', bold = true } },
      { NeogitDiffHeader = { inherit = 'Headline2', bold = true } },
      { NeogitFold = { bg = { from = 'CursorLine', alter = -0.25 } } },
      { NeogitCursorLine = { bg = { from = 'CursorLine' }, fg = { from = 'Normal' } } },
      { HlSearchNear = { fg = { from = 'Search' }, bg = 'NONE' } },
      { HlSearchLens = { fg = { from = 'Search' }, bg = 'NONE' } },
      { GitConflictCurrent = { bg = { from = 'DiffAdd', alter = -0.5 } } },
      { GitConflictCurrentLabel = { inherit = 'DiffAdd' } },
      { GitConflictIncoming = { bg = { from = 'DiffDelete', alter = -0.5 } } },
      { GitConflictIncomingLabel = { inherit = 'DiffDelete' } },
      { GitConflictAncestor = { bg = { from = 'DiffText', alter = -0.5 } } },
      { GitConflictAncestorLabel = { inherit = 'DiffText' } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if hls then highlight.all(hls) end
end

local function user_highlights()
  general_overrides()
  colorscheme_overrides()
  set_sidebar_highlight()
end

rvim.augroup('UserHighlights', {
  event = { 'ColorScheme' },
  command = function() user_highlights() end,
}, {
  event = { 'FileType' },
  pattern = sidebar_fts,
  command = function() on_sidebar_enter() end,
})
