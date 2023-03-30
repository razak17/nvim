if not rvim then return end

local hl = rvim.highlight

local function general_overrides()
  hl.all({
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
    { StatusColSep = { fg = { from = 'Comment' }, bg = { from = 'Normal' } } },
    ------------------------------------------------------------------------------//
    --  Semantic tokens
    ------------------------------------------------------------------------------//
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.type.variable'] = { link = '@variable' } },
    { ['@lsp.typemod.variable.global'] = { bold = true, inherit = '@constant.builtin' } },
    { ['@lsp.typemod.variable.defaultLibrary'] = { italic = true } },
    { ['@lsp.typemod.variable.readonly.typescript'] = { clear = true } },
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
    ------------------------------------------------------------------------------------------------
    -- LSP
    ------------------------------------------------------------------------------------------------
    { LspCodeLens = { link = 'NonText' } },
    -- This represents when a reference is assigned which is more interesting than regular
    -- occurrences so should be highlighted more distinctly
    { LspReferenceWrite = { bold = true } },
  })
end

local function set_sidebar_highlight()
  hl.all({
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -0.43 } } },
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
  'packer',
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
      { ['@variable'] = { fg = { from = '@none' } } },
    },
  }
  local hls = overrides[vim.g.colors_name]
  if not hls then return end

  hl.all(hls)
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
