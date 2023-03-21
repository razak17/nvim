if not rvim then return end

local hl = rvim.highlight

local function general_overrides()
  hl.all({
    { mkdLineBreak = { link = 'NONE' } },
    { LineNr = { background = 'NONE' } },
    { ErrorMsg = { background = 'NONE' } },
    ------------------------------------------------------------------------------------------------
    -- colorscheme overrides
    ------------------------------------------------------------------------------------------------
    { QuickFixLine = { bg = { from = 'Cursorline' }, fg = 'NONE' } },
    -- Neither the sign column or end of buffer highlights require an explicit background
    -- they should both just use the background that is in the window they are in.
    -- if either are specified this can lead to issues when a winhighlight is set
    { SignColumn = { background = 'NONE' } },
    { EndOfBuffer = { background = 'NONE' } },
    { GitSignsCurrentLineBlame = { link = 'Comment' } },
    { StatusColSep = { fg = { from = 'WinSeparator' }, bg = { from = 'Normal' } } },
    ------------------------------------------------------------------------------//
    --  Semantic tokens
    ------------------------------------------------------------------------------//
    { ['@lsp.type.parameter'] = { italic = true, foreground = { from = 'Normal' } } },
    { ['@lsp.type.variable'] = { clear = true } },
    { ['@lsp.typemod.variable.global'] = { bold = true, inherit = '@constant.builtin' } },
    { ['@lsp.typemod.variable.readonly.typescript'] = { clear = true } },

    ------------------------------------------------------------------------------------------------
    -- Treesitter
    ------------------------------------------------------------------------------------------------
    { ['@keyword.return'] = { italic = true, foreground = { from = 'Keyword' } } },
    { ['@parameter'] = { italic = true, bold = true, foreground = 'NONE' } },
    { ['@error'] = { foreground = 'fg', background = 'NONE' } },
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
    { PanelDarkBackground = { bg = { from = 'Normal', alter = -43 } } },
    { PanelDarkHeading = { inherit = 'PanelDarkBackground', bold = true } },
    { PanelBackground = { background = { from = 'Normal', alter = -8 } } },
    { PanelHeading = { inherit = 'PanelBackground', bold = true } },
    { PanelVertSplit = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } } },
    {
      PanelVertSplitAlt = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    },
    {
      PanelWinSeparator = { inherit = 'PanelBackground', foreground = { from = 'WinSeparator' } },
    },
    { PanelStNC = { link = 'PanelWinSeparator' } },
    { PanelSt = { background = { from = 'Visual', alter = -10 } } },
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
      {
        FloatTitle = {
          bg = { from = 'FloatTitle', alter = -60 },
          fg = { from = 'Normal' },
        },
      },
      { CursorLine = { bg = { from = 'CursorLine', alter = -20 } } },
      { VertSplit = { fg = { from = 'VertSplit', alter = -50 } } },
      { Dim = { inherit = 'VertSplit' } },
      { TelescopePreviewBorder = { fg = { from = 'TelescopePreviewBorder', alter = -50 } } },
      { TelescopePromptPrefix = { fg = { from = 'TelescopePromptPrefix', alter = -30 } } },
      { StatusLine = { bg = { from = 'StatusLine', alter = -20 } } },
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
