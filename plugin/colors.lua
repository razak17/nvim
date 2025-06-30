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
    ['lunar'] = {
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

local function set_cheatsheet_highlight()
  highlight.all({
    {
      NvChHeading = {
        fg = { from = 'Dim', alter = -0.5 },
        bg = { from = 'Directory', attr = 'fg' },
      },
    },
    { NvChAsciiHeader = { link = 'Debug' } },
    { NvChSection = { link = 'NormalFloat' } },
    { NvChHeadblue = { bg = '#61AFEF', fg = '#282C34' } },
    { NvChHeadred = { bg = '#E06C75', fg = '#282C34' } },
    { NvChHeadgreen = { bg = '#98C379', fg = '#282C34' } },
    { NvChHeadyellow = { bg = '#E5C07B', fg = '#282C34' } },
    { NvChHeadorange = { bg = '#D19A66', fg = '#282C34' } },
    { NvChHeadbaby_pink = { bg = '#FF6AC1', fg = '#282C34' } },
    { NvChHeadpurple = { bg = '#C678DD', fg = '#282C34' } },
    { NvChHeadwhite = { bg = '#ABB2BF', fg = '#282C34' } },
    { NvChHeadcyan = { bg = '#56B6C2', fg = '#282C34' } },
    { NvChHeadvibrant_green = { bg = '#98C379', fg = '#282C34' } },
    { NvChHeadteal = { bg = '#008080', fg = '#b3deef' } },
  })
end

local function user_highlights()
  general_overrides()
  colorscheme_overrides()
  if not transparent then set_sidebar_highlight() end
  set_cheatsheet_highlight()
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

ar.load_colorscheme(ar_config.colorscheme)
