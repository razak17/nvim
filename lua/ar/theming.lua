local variant = ar.config.colorscheme.variant
local transparent = ar.config.ui.transparent.enable

---@class HlOverride
---@field default table?
---@field popup table?
---@field completion table?
---@field lsp table?
---@field picker table?
---@field plugin table?

---@param overrides? table
---@return table
local function generate_popup_overrides(overrides)
  local hls = {
    {
      FloatTitle = {
        bg = { from = 'Type', attr = 'fg', alter = -0.45 },
        fg = { from = 'CursorLineNr' },
      },
    },
  }

  local bg = vim.api.nvim_get_option_value('background', { scope = 'global' })

  if variant == 'fill' and not transparent then
    ar.list_insert(hls, {
      {
        NormalFloat = {
          bg = { from = 'Normal', alter = bg == 'dark' and 0.25 or -0.1 },
          fg = { from = 'Normal', alter = -0.15 },
        },
      },
      {
        FloatBorder = {
          bg = { from = 'NormalFloat' },
          fg = { from = 'NormalFloat', attr = 'bg' },
        },
      },
    })
  end

  if variant == 'outline' or transparent then
    ar.list_insert(hls, {
      {
        NormalFloat = {
          bg = { from = 'Normal' },
          fg = { from = 'Normal', alter = -0.15 },
        },
      },
      { FloatBorder = { link = 'VertSplit' } },
    })
  end

  ar.list_insert(hls, overrides or {})
  return hls
end

---@param overrides? table
---@return table
local function generate_completion_overrides(overrides)
  local hls = {
    { Pmenu = { link = 'NormalFloat' } },
    { PmenuBorder = { link = 'FloatBorder' } },
    {
      PmenuKind = {
        bg = 'NONE',
        fg = { from = 'NonText' },
        italic = true,
        bold = true,
      },
    },
    { PmenuMatch = { fg = { from = 'Normal' }, bold = true } },
    { PmenuExtra = { bg = 'NONE', fg = { from = 'NonText' } } },
    { PmenuSel = { bg = { from = 'Visual' }, fg = 'NONE', reverse = false } },
    { PmenuExtraSel = { link = 'PmenuSel' } },
    {
      PmenuKindSel = {
        bg = { from = 'PmenuSel' },
        fg = { from = 'PmenuKind' },
        italic = true,
        bold = true,
      },
    },
    { PmenuThumb = { bg = { from = 'PmenuThumb', alter = -0.4 } } },
    { BlinkCmpDocBorder = { link = 'PmenuBorder' } },
    { BlinkCmpSource = { link = 'PmenuKind' } },
    { BlinkCmpLabel = { fg = { from = 'Pmenu' } } },
    { BlinkCmpLabelDetail = { link = 'PmenuExtra' } },
    { BlinkCmpLabelMatch = { link = 'PmenuMatch' } },
    { BlinkCmpLabelDescription = { link = 'PmenuExtra' } },
    { BlinkCmpLabelDeprecated = { strikethrough = true, link = 'Comment' } },
  }
  ar.list_insert(hls, overrides or {})
  return hls
end

---@param overrides? table
---@return table
local function generate_lsp_overrides(overrides)
  local hls = {
    {
      LspReferenceText = {
        bg = 'NONE',
        underline = true,
        sp = { from = 'Comment', attr = 'fg', alter = -0.45 },
      },
    },
    { LspReferenceRead = { bg = { from = 'Visual', alter = -0.1 } } },
    { LspReferenceWrite = { link = 'LspReferenceText', bold = false } },
    { LspReferenceTarget = { inherit = 'Dim', bold = true } },
  }
  ar.list_insert(hls, overrides or {})
  return hls
end

---@param overrides? table
---@return table
local function generate_picker_overrides(overrides)
  local hls = {
    { PickerNormal = { link = 'NormalFloat' } },
    { PickerTitle = { link = 'FloatTitle' } },
    { PickerBorder = { link = 'FloatBorder' } },
    {
      PickerToggle = {
        bg = { from = 'FloatTitle' },
        fg = { from = 'Directory' },
        italic = true,
      },
    },
  }

  if variant == 'fill' then
    ar.list_insert(hls, {
      { PickerPreview = { bg = { from = 'NormalFloat', alter = -0.1 } } },
      {
        PickerPreviewBorder = {
          bg = { from = 'PickerPreview' },
          fg = { from = 'PickerPreview', attr = 'bg' },
        },
      },
      { PickerPrompt = { bg = { from = 'NormalFloat', alter = 0.15 } } },
      {
        PickerPromptBorder = {
          bg = { from = 'PickerPrompt' },
          fg = { from = 'PickerPrompt', attr = 'bg' },
        },
      },
    })
  end

  if variant == 'outline' then
    ar.list_insert(hls, {
      { PickerPreview = { bg = { from = 'NormalFloat' } } },
      { PickerPreviewBorder = { fg = { from = 'FloatBorder' } } },
      { PickerPrompt = { bg = { from = 'NormalFloat' } } },
      { PickerPromptBorder = { fg = { from = 'FloatBorder' } } },
    })
  end

  ar.list_insert(hls, {
    { SnacksPickerPrompt = { bg = 'NONE' } },
    { SnacksTitle = { link = 'PickerTitle' } },
    { SnacksInputNormal = { link = 'PickerPrompt' } },
    { SnacksInputTitle = { link = 'PickerTitle' } },
    { SnacksInputBorder = { link = 'PickerPromptBorder' } },
    { SnacksPickerToggle = { link = 'PickerToggle' } },
    { SnacksPicker = { link = 'PickerNormal' } },
    { SnacksPickerTitle = { link = 'PickerTitle' } },
    { SnacksPickerBorder = { link = 'PickerBorder' } },
    { SnacksPickerInput = { link = 'PickerNormal' } },
    { SnacksPickerInputBorder = { link = 'PickerBorder' } },
    { SnacksPickerPreview = { link = 'PickerPreview' } },
    { SnacksPickerPreviewBorder = { link = 'PickerPreviewBorder' } },
    { FzfLuaTitleFlags = { link = 'PickerToggle' } },
    { FzfLuaNormal = { link = 'PickerNormal' } },
    { FzfLuaTitle = { link = 'PickerTitle' } },
    { FzfLuaBorder = { link = 'PickerBorder' } },
    { FzfLuaPreviewNormal = { link = 'PickerPreview' } },
    { FzfLuaPreviewBorder = { link = 'PickerPreviewBorder' } },
    { TelescopeNormal = { link = 'PickerNormal' } },
    { TelescopeTitle = { link = 'PickerTitle' } },
    { TelescopeBorder = { link = 'PickerBorder' } },
    { TelescopeResultsNormal = { link = 'PickerNormal' } },
    { TelescopeResultsTitle = { link = 'PickerTitle' } },
    { TelescopeResultsBorder = { link = 'PickerBorder' } },
    { TelescopePromptNormal = { link = 'PickerPrompt' } },
    { TelescopePromptTitle = { link = 'PickerTitle' } },
    { TelescopePromptBorder = { link = 'PickerPromptBorder' } },
    { TelescopePreviewNormal = { link = 'PickerPreview' } },
    { TelescopePreviewTitle = { link = 'PickerTitle' } },
    { TelescopePreviewBorder = { link = 'PickerPreviewBorder' } },
  })

  ar.list_insert(hls, overrides or {})
  return hls
end

---@param overrides? table
---@return table
local function generate_plugin_overrides(overrides)
  local hls = {
    { SnacksNotifierHistory = { link = 'PickerNormal' } },
  }
  ar.list_insert(hls, overrides or {})
  return hls
end

---@param overrides? HlOverride
---@return table
local function generate_overrides(overrides)
  overrides = overrides or {}
  local hls = {}
  ar.list_insert(hls, overrides.default or {})
  ar.list_insert(hls, {
    { Winbar = { link = 'Variable' } },
    { WinbarNC = { link = 'NonText' } },
    { WinSeparator = { inherit = 'WinSeparator', bg = 'NONE' } },
    { MsgSeparator = { link = 'WinSeparator' } },
    { VertSplit = { link = 'WinSeparator' } },
    { IndentBlanklineChar = { link = 'VertSplit' } },
    { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
  })
  -- Order matters here
  ar.list_insert(
    hls,
    generate_popup_overrides(overrides.popup),
    generate_completion_overrides(overrides.completion),
    generate_lsp_overrides(overrides.lsp),
    generate_picker_overrides(overrides.picker),
    generate_plugin_overrides(overrides.plugin)
  )
  return hls
end

---@param theme string
---@param overrides? HlOverride
---@param should_generate? boolean
local function apply_overrides(theme, overrides, should_generate)
  local theme_overrides = overrides and overrides.default or {}
  if should_generate then theme_overrides = generate_overrides(overrides) end
  ar.augroup(theme .. '-theme', {
    event = { 'ColorScheme' },
    pattern = { theme },
    command = function() ar.highlight.all(theme_overrides) end,
  })
end

local function get_statusline_palette(colorscheme)
  local hl = ar.highlight
  local P = {
    bg_dark = hl.get('StatusLine', 'bg'),
    fg = hl.get('Normal', 'fg'),
    blue = hl.get('Directory', 'fg'),
    dark_orange = hl.get('WarningMsg', 'fg'),
    error_red = hl.get('NvimInternalError', 'bg'),
    pale_red = ar.highlight.get('Error', 'fg'),
    pale_blue = hl.get('DiagnosticInfo', 'bg'),
    comment = hl.get('Comment', 'fg'),
    forest_green = hl.get('DiffAdd', 'fg'),
    lightgreen = hl.get('DiagnosticVirtualTextHint', 'bg'),
  }
  local overrides = {
    default = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.3),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.55),
      pale_red = hl.get('DiagnosticError', 'fg'),
      pale_blue = hl.get('DiagnosticInfo', 'fg'),
      forest_green = hl.get('DiffAdd', 'bg'),
      lightgreen = hl.get('DiagnosticVirtualTextHint', 'fg'),
    },
    habamax = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.55),
      pale_red = ar.highlight.get('ErrorMsg', 'fg'),
    },
    peachpuff = {
      bg_dark = hl.get('CursorLine', 'bg'),
      fg = hl.get('Comment', 'fg'),
      yellowgreen = hl.get('String', 'fg'),
      dark_orange = hl.tint(hl.get('WarningMsg', 'fg'), -0.2),
      error_red = hl.tint(hl.get('Error', 'fg'), -0.4),
      pale_red = hl.tint(hl.get('Error', 'fg'), 0.2),
      pale_blue = hl.tint(hl.get('DiagnosticInfo', 'fg'), -0.2),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
      orange = hl.get('Constant', 'fg'),
    },
    retrobox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
      blue = hl.tint(hl.get('Changed', 'fg'), 0.2),
    },
    slate = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
      fg = hl.tint(hl.get('Comment', 'fg'), 0.8),
      blue = hl.get('DiffChange', 'bg'),
    },
    vim = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.55),
    },
    wildcharm = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.6),
    },
    afterglow = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    ashen = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    bamboo = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    cyberdream = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.3),
    },
    darcubox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
      dark_orange = hl.get('Label', 'fg'),
    },
    darkmatter = {
      dark_orange = hl.get('Label', 'fg'),
      error_red = hl.get('TSType', 'fg'),
      comment = hl.tint(hl.get('LineNr', 'fg'), -0.15),
    },
    darkvoid = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    ['doom-one'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.05),
    },
    eldritch = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    everforest = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
      blue = hl.get('DiagnosticInfo', 'fg'),
    },
    evergarden = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    ferriouscolor = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('Changed', 'fg'),
    },
    glowbeam = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    ['github_dark'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
    },
    ['github_dark_dimmed'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.2),
    },
    ['github_dark_tritanopia'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.55),
    },
    gruvbox = {
      bg_dark = hl.tint(hl.get('Normal', 'bg'), 0.25),
      blue = hl.get('Changed', 'fg'),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
    },
    horizon = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
      blue = hl.get('Changed', 'fg'),
    },
    iceclimber = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.25),
    },
    jellybeans = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    kanagawa = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    lavish = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.25),
    },
    ['mono-jade'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    makurai_dark = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    naysayer = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    nightfox = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.15),
    },
    ['night-owl'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.05),
    },
    ['no-clown-fiesta'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.2),
    },
    ['oh-lucy'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    poimandres = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
    },
    rasmus = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      comment = hl.tint(hl.get('Comment', 'fg'), 0.15),
    },
    ronny = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.25),
      blue = hl.get('Changed', 'fg'),
    },
    ['rose-pine'] = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.05),
    },
    serenity = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('Define', 'fg'),
    },
    shadow = {
      bg_dark = hl.tint(hl.get('NormalFloat', 'bg'), 0.25),
      comment = hl.tint(hl.get('Comment', 'fg'), 0.45),
    },
    sunbather = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
    },
    tokyonight = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
    },
    wildberries = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), 0.15),
      blue = hl.get('DiagnosticInfo', 'fg'),
      comment = hl.tint(hl.get('LineNr', 'fg'), -0.15),
    },
    zenbones = {
      bg_dark = hl.tint(hl.get('CursorLine', 'bg'), -0.1),
      blue = hl.get('DiagnosticInfo', 'fg'),
    },
    zenburn = {
      bg_dark = hl.tint(hl.get('Normal', 'bg'), 0.25),
      dark_orange = hl.get('Function', 'fg'),
      pale_blue = hl.tint(hl.get('DiagnosticInfo', 'fg'), -0.2),
      forest_green = hl.tint(hl.get('DiffAdd', 'bg'), -0.3),
      lightgreen = hl.tint(hl.get('DiagnosticVirtualTextHint', 'fg'), -0.2),
    },
  }
  if overrides[colorscheme] then
    return vim.tbl_deep_extend('force', P, overrides[colorscheme])
  end
  if colorscheme == 'onedark' and ar.has('onedark.nvim') then
    P = require('onedark.palette')
  end
  return P
end

return {
  generate_popup_overrides = generate_popup_overrides,
  generate_completion_overrides = generate_completion_overrides,
  generate_lsp_overrides = generate_lsp_overrides,
  generate_picker_overrides = generate_picker_overrides,
  generate_plugin_overrides = generate_plugin_overrides,
  generate_overrides = generate_overrides,
  apply_overrides = apply_overrides,
  get_statusline_palette = get_statusline_palette,
}
