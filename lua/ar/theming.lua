local variant = ar_config.colorscheme.variant

---@return table
local function generate_popup_overrides()
  local overrides = {
    { FloatTitle = { bg = { from = 'Visual' }, fg = { from = 'Type' } } },
  }

  if variant == 'fill' then
    ar.list_insert(overrides, {
      {
        NormalFloat = {
          bg = { from = 'Normal', alter = 0.25 },
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

  if variant == 'outline' then
    ar.list_insert(overrides, {
      {
        NormalFloat = {
          bg = { from = 'Normal' },
          fg = { from = 'Normal', alter = -0.15 },
        },
      },
      { FloatBorder = { link = 'VertSplit' } },
    })
  end
  return overrides
end

---@return table
local function generate_completion_overrides()
  return {
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
end

---@return table
local function generate_lsp_overrides()
  return {
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
end

---@return table
local function generate_picker_overrides()
  local overrides = {
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
    ar.list_insert(overrides, {
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
    ar.list_insert(overrides, {
      { PickerPreview = { bg = { from = 'NormalFloat' } } },
      { PickerPreviewBorder = { fg = { from = 'FloatBorder' } } },
      { PickerPrompt = { bg = { from = 'NormalFloat' } } },
      { PickerPromptBorder = { fg = { from = 'FloatBorder' } } },
    })
  end

  ar.list_insert(overrides, {
    { SnacksTitle = { link = 'PickerTitle' } },
    { SnacksInputNormal = { link = 'PickerPrompt' } },
    { SnacksInputTitle = { link = 'PickerTitle' } },
    { SnacksInputBorder = { link = 'PickerPromptBorder' } },
    { SnacksPickerToggle = { link = 'PickerToggle' } },
    { SnacksPicker = { link = 'PickerNormal' } },
    { SnacksPickerTitle = { link = 'PickerTitle' } },
    { SnacksPickerBorder = { link = 'PickerBorder' } },
    -- { SnacksPickerInput = { link = 'PickerPrompt' } },
    -- { SnacksPickerInputBorder = { link = 'PickerPromptBorder' } },
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

  return overrides
end

---@return table
local function generate_plugin_overrides()
  local overrides = {
    { SnacksNotifierHistory = { link = 'PickerNormal' } },
  }
  return overrides
end

---@param override? table
---@return table
local function generate_overrides(override)
  local overrides = {
    { StatusLine = { bg = 'NONE', reverse = false } },
    { Winbar = { link = 'Variable' } },
    { WinbarNC = { link = 'NonText' } },
  }
  if not ar.falsy(override) then ar.list_insert(overrides, override) end
  ar.list_insert(overrides, {
    { MsgSeparator = { link = 'WinSeparator' } },
    { VertSplit = { link = 'WinSeparator' } },
    { IndentBlanklineChar = { link = 'VertSplit' } },
    { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
  })
  -- Order matters here
  ar.list_insert(
    overrides,
    generate_popup_overrides(),
    generate_completion_overrides(),
    generate_lsp_overrides(),
    generate_picker_overrides(),
    generate_plugin_overrides()
  )
  return overrides
end

---@param theme string
---@param overrides table
---@param should_generate boolean
local function apply_overrides(theme, overrides, should_generate)
  local theme_overrides = overrides or {}
  if should_generate then theme_overrides = generate_overrides(overrides) end
  ar.augroup(theme .. '-theme', {
    event = { 'ColorScheme' },
    pattern = { theme },
    command = function() ar.highlight.all(theme_overrides) end,
  })
end

return {
  generate_popup_overrides = generate_popup_overrides,
  generate_completion_overrides = generate_completion_overrides,
  generate_lsp_overrides = generate_lsp_overrides,
  generate_picker_overrides = generate_picker_overrides,
  generate_plugin_overrides = generate_plugin_overrides,
  generate_overrides = generate_overrides,
  apply_overrides = apply_overrides,
}
