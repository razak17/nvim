local scheme_switcher = require('ar.scheme_switcher')
local colorscheme = scheme_switcher.get_current_colorscheme()
local variant = ar_config.colorscheme.variant

local function is_colorscheme(name) return name == colorscheme end

--- Get colorscheme cond
---@param names table
---@return boolean
local function get_cond(names)
  if ar.plugins.niceties or vim.list_contains(names, colorscheme) then
    return true
  end
  return not ar.plugins.minimal and vim.tbl_contains(names, colorscheme)
end

---@param names table
---@return number
local function get_priority(names)
  if ar.plugins.niceties then return 1000 end
  for _, theme in ipairs(names) do
    if is_colorscheme(theme) then return 1000 end
  end
  return 50
end

---@param names table
---@return table
local function get_event(names)
  if ar.plugins.niceties then return { 'UiEnter' } end
  for _, theme in ipairs(names) do
    if is_colorscheme(theme) then return { 'UiEnter' } end
  end
  return { 'VeryLazy' }
end

local function generate_popup_overrides(opts)
  local overrides = {
    { FloatTitle = { bg = { from = 'Visual' }, fg = { from = 'Normal' } } },
  }
  ar.list_insert(overrides, opts)

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
    { PmenuExtra = { fg = { from = 'NonText' } } },
    { PmenuSel = { bg = { from = 'Visual' }, fg = 'NONE', reverse = false } },
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

local function generate_lsp_overrides()
  return {
    {
      LspReferenceText = {
        bg = 'NONE',
        underline = true,
        sp = { from = 'Comment', attr = 'fg', alter = -0.2 },
      },
    },
    { LspReferenceRead = { bg = { from = 'Visual', alter = -0.1 } } },
    { LspReferenceWrite = { link = 'LspReferenceText', bold = false } },
    { LspReferenceTarget = { inherit = 'Dim', bold = true } },
  }
end

local function generate_picker_overrides()
  local overrides = {
    {
      SnacksPickerToggle = {
        bg = { from = 'FloatTitle' },
        fg = { from = 'DiagnosticVirtualTextInfo' },
        italic = true,
      },
    },
  }

  if variant == 'fill' then
    ar.list_insert(overrides, {
      {
        SnacksPickerPreview = {
          bg = { from = 'NormalFloat', alter = -0.1 },
        },
      },
      {
        SnacksPickerPreviewBorder = {
          bg = { from = 'SnacksPickerPreview' },
          fg = { from = 'SnacksPickerPreview', attr = 'bg' },
        },
      },
    })
  end

  if variant == 'outline' then
    ar.list_insert(overrides, {
      { SnacksPickerPreview = { bg = { from = 'NormalFloat' } } },
      { SnacksPickerPreviewBorder = { fg = { from = 'FloatBorder' } } },
    })
  end

  ar.list_insert(overrides, {
    { SnacksPickerBorder = { link = 'FloatBorder' } },
    { SnacksTitle = { link = 'FloatTitle' } },
    { SnacksInputTitle = { link = 'SnacksTitle' } },
    { SnacksPickerTitle = { link = 'SnacksTitle' } },
    { FzfLuaNormal = { link = 'SnacksPicker' } },
    { FzfLuaTitle = { link = 'SnacksPickerTitle' } },
    { FzfLuaBorder = { link = 'SnacksPickerBorder' } },
    { FzfLuaPreviewNormal = { link = 'SnacksPickerPreview' } },
    { FzfLuaPreviewBorder = { link = 'SnacksPickerPreviewBorder' } },
    { TelescopeNormal = { link = 'SnacksPicker' } },
    { TelescopeTitle = { link = 'SnacksPickerTitle' } },
    { TelescopeBorder = { link = 'SnacksPickerBorder' } },
    { TelescopePreviewNormal = { link = 'SnacksPickerPreview' } },
    { TelescopePreviewBorder = { link = 'SnacksPickerPreviewBorder' } },
  })

  return overrides
end

---@param overrides table
---@return table
local function generate_overrides(overrides)
  local generated_overrides = {
    { StatusLine = { bg = 'NONE' } },
    { Winbar = { link = 'Variable' } },
    { WinbarNC = { link = 'LineNr' } },
  }
  ar.list_insert(generated_overrides, generate_popup_overrides())
  ar.list_insert(generated_overrides, overrides)
  ar.list_insert(generated_overrides, generate_completion_overrides())
  ar.list_insert(generated_overrides, generate_lsp_overrides())
  ar.list_insert(generated_overrides, generate_picker_overrides())
  return generated_overrides
end

---@param theme string
---@param overrides table
---@param should_generate boolean
local function apply_overrides(theme, overrides, should_generate)
  local theme_overrides = overrides
  if should_generate then theme_overrides = generate_overrides(overrides) end
  ar.augroup(theme .. '-theme', {
    event = { 'ColorScheme' },
    pattern = { theme },
    command = function() ar.highlight.all(theme_overrides) end,
  })
end

return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  {
    'razak17/onedark.nvim',
    cond = get_cond({ 'onedark' }),
    priority = get_priority({ 'onedark' }),
    event = get_event({ 'onedark' }),
    opts = { variant = variant },
    init = function()
      local overrides = {
        { MsgSeparator = { link = 'VertSplit' } },
        { Dim = { inherit = 'VertSplit' } },
        { NeorgContext = { inherit = 'Normal' } },
        -- { ['@variable'] = { fg = { from = '@none' } } },
        { dmapWin = { inherit = 'Normal' } },
        { Strict = { link = 'DiffDeleteAlt' } },
      }
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      apply_overrides('onedark', overrides)
    end,
  },
  {
    'vague2k/vague.nvim',
    cond = get_cond({ 'vague' }),
    priority = get_priority({ 'vague' }),
    event = get_event({ 'vague' }),
    opts = {
      transparent = ar_config.ui.transparent.enable,
      colors = { floatBorder = '#252530' },
    },
    init = function()
      local overrides = {
        { StatusLine = { bg = 'NONE' } },
        { FloatBorder = { link = 'VertSplit' } },
        { FloatTitle = { bg = { from = 'Visual' }, fg = { from = 'Normal' } } },
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
        {
          SnacksPickerToggle = { bg = { from = 'FloatTitle' }, italic = true },
        },
        { TelescopeTitle = { link = 'FloatTitle' } },
      }
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      apply_overrides('vague', overrides)
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    cond = get_cond({ 'catppuccin' }),
    priority = get_priority({ 'catppuccin' }),
    event = get_event({ 'catppuccin' }),
  },
  {
    'rebelot/kanagawa.nvim',
    cond = get_cond({ 'kanagawa' }),
    priority = get_priority({ 'kanagawa' }),
    event = get_event({ 'kanagawa' }),
  },
  {
    'edeneast/nightfox.nvim',
    cond = get_cond({ 'nightfox' }),
    priority = get_priority({ 'nightfox' }),
    event = get_event({ 'nightfox' }),
  },
  {
    'stefanvanburen/rams.vim',
    cond = get_cond({ 'rams' }),
    priority = get_priority({ 'rams' }),
    event = get_event({ 'rams' }),
    init = function()
      apply_overrides('rams', {
        { CursorLine = { bg = { from = 'Normal', alter = 0.9 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { LineNr = { fg = { from = 'LineNr', alter = -0.4 } } },
        {
          Visual = {
            bg = { from = 'CursorLine', alter = 0.3 },
            reverse = false,
          },
        },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.65 } } },
        {
          GitSignsAdd = {
            fg = { from = 'DiffAdd', attr = 'bg', alter = 1.1 },
          },
        },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.6 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  ------------------------------------------------------------------------------
  -- Dark
  {
    'biisal/blackhole',
    cond = get_cond({ 'blackhole' }),
    priority = get_priority({ 'blackhole' }),
    event = get_event({ 'blackhole' }),
  },
  {
    'bettervim/yugen.nvim',
    cond = get_cond({ 'yugen' }),
    priority = get_priority({ 'yugen' }),
    event = get_event({ 'yugen' }),
  },
  {
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    cond = get_cond({ 'moonfly' }),
    priority = get_priority({ 'moonfly' }),
    event = get_event({ 'moonfly' }),
  },
  {
    'cooperuser/glowbeam.nvim',
    cond = get_cond({ 'glowbeam' }),
    priority = get_priority({ 'glowbeam' }),
    event = get_event({ 'glowbeam' }),
  },
  {
    'danilo-augusto/vim-afterglow',
    cond = get_cond({ 'afterglow' }),
    priority = get_priority({ 'afterglow' }),
    event = get_event({ 'afterglow' }),
  },
  {
    'kuri-sun/yoda.nvim',
    cond = get_cond({ 'yoda' }),
    priority = get_priority({ 'yoda' }),
    event = get_event({ 'yoda' }),
    init = function()
      local overrides = {
        { CursorLine = { bg = { from = 'Normal', alter = 2.7 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.3 } } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.1 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'WinSeparator' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptNormal = { link = 'TelescopeNormal' } },
        { TelescopePromptTitle = { bg = { from = 'TelescopeTitle' } } },
        { TelescopePreviewTitle = { link = 'TelescopePromptTitle' } },
        { TelescopeBorder = { link = 'SnacksPickerBorder' } },
        { TelescopePromptBorder = { link = 'SnacksPickerBorder' } },
      })
      apply_overrides('yoda', overrides)
    end,
  },
  {
    'razak17/mapledark.nvim',
    cond = function() return colorscheme == 'mapledark' end,
    priority = get_priority({ 'mapledark' }),
    event = get_event({ 'mapledark' }),
    init = function()
      apply_overrides('mapledark', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
    opts = { disable_plugin_highlights = false, plugins = { 'lazy' } },
  },
  ------------------------------------------------------------------------------
  -- Warm
  {
    'savq/melange-nvim',
    cond = get_cond({ 'melange' }),
    priority = get_priority({ 'melange' }),
    event = get_event({ 'melange' }),
  },
  {
    'morhetz/gruvbox',
    cond = get_cond({ 'gruvbox' }),
    priority = get_priority({ 'gruvbox' }),
    event = get_event({ 'gruvbox' }),
  },
  {
    'jnurmine/Zenburn',
    cond = get_cond({ 'zenburn' }),
    priority = get_priority({ 'zenburn' }),
    event = get_event({ 'zenburn' }),
  },
  {
    'darianmorat/gruvdark.nvim',
    cond = get_cond({ 'gruvdark' }),
    priority = get_priority({ 'gruvdark' }),
    event = get_event({ 'gruvdark' }),
  },
  {
    'alexkotusenko/nightgem.nvim',
    cond = get_cond({ 'nightgem' }),
    priority = get_priority({ 'nightgem' }),
    event = get_event({ 'nightgem' }),
    init = function()
      apply_overrides('nightgem', {
        { CursorLine = { bg = { from = 'CursorLine', alter = -0.2 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
        {
          GitSignsAdd = {
            fg = { from = 'DiffAdd', attr = 'bg', alter = 1.1 },
          },
        },
        { WinSeparator = { fg = { from = 'Comment' } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  {
    'xeind/nightingale.nvim',
    cond = get_cond({ 'nightingale' }),
    priority = get_priority({ 'nightingale' }),
    event = get_event({ 'nightingale' }),
    init = function()
      apply_overrides('nightingale', {
        { IndentBlanklineChar = { link = 'WinSeparator' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  ------------------------------------------------------------------------------
  -- Monochrome
  {
    'webhooked/kanso.nvim',
    cond = get_cond({ 'kanso' }),
    priority = get_priority({ 'kanso' }),
    event = get_event({ 'kanso' }),
    init = function()
      apply_overrides('kanso', {
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  {
    'zenbones-theme/zenbones.nvim',
    cond = get_cond({ 'zenbones' }),
    priority = get_priority({ 'zenbones' }),
    event = get_event({ 'zenbones' }),
    init = function()
      apply_overrides('zenbones', {
        { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Folded = { bg = { from = 'Folded', alter = -0.2 } } },
        { WinSeparator = { fg = { from = 'VertSplit', alter = -0.35 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
    dependencies = 'rktjmp/lush.nvim',
  },
  {
    'lucasadelino/conifer.nvim',
    cond = get_cond({ 'conifer' }),
    priority = get_priority({ 'conifer' }),
    event = get_event({ 'conifer' }),
    opts = { transparent = ar_config.ui.transparent.enable },
    init = function()
      apply_overrides('conifer', {
        { DiffAdd = { bg = { from = 'DiffAdd', alter = 3.15 } } },
        { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg' } } },
        { WinSeparator = { fg = { from = 'LineNr' } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  {
    'KijitoraFinch/nanode.nvim',
    cond = function() return colorscheme == 'nanode' end,
    priority = get_priority({ 'nanode' }),
    event = get_event({ 'nanode' }),
    opts = { transparent = ar_config.ui.transparent.enable },
    init = function()
      apply_overrides('nanode', {
        { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
        { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.8 } } },
        { CursorLineNr = { link = 'String' } },
        { LineNr = { fg = { from = 'LineNr', alter = -0.3 } } },
        { Visual = { bg = { from = 'Visual', alter = -0.6 }, fg = 'NONE' } },
        { Dim = { fg = { from = 'Comment', alter = -0.3 } } },
        { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { FloatTitle = { bg = { from = 'FloatTitle', alter = -0.55 } } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = 0.85 } } },
        { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg' } } },
        { DiffChange = { bg = { from = 'DiffChange', alter = 0.85 } } },
        { GitSignsChange = { fg = { from = 'DiffChange', attr = 'bg' } } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.4 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  {
    'stevedylandev/darkmatter-nvim',
    cond = get_cond({ 'darkmatter' }),
    priority = get_priority({ 'darkmatter' }),
    event = get_event({ 'darkmatter' }),
  },
  {
    'cdmill/neomodern.nvim',
    -- enabled = false,
    cond = get_cond({ 'neomodern' }),
    priority = get_priority({ 'neomodern' }),
    event = get_event({ 'neomodern' }),
    opts = {
      theme = 'iceclimber', -- 'iceclimber' | 'gyokuro' | 'hojicha' | 'roseprime'
      variant = 'dark', -- 'light' | 'dark', or set via vim.o.background
    },
    config = function(_, opts)
      require('neomodern').setup(opts)
      if colorscheme == 'neomodern' then require('neomodern').load() end
    end,
  },
  {
    'ficcdaf/ashen.nvim',
    cond = get_cond({ 'ashen' }),
    priority = get_priority({ 'ashen' }),
    event = get_event({ 'ashen' }),
  },
  {
    'slugbyte/lackluster.nvim',
    cond = get_cond({ 'lackluster' }),
    priority = get_priority({ 'lackluster' }),
    event = get_event({ 'lackluster' }),
    init = function()
      local overrides = {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Visual = { link = 'CursorLine' } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.4 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(
        overrides,
        generate_popup_overrides({
          {
            FloatTitle = {
              bg = { from = 'CursorLine' },
              fg = { from = 'Normal' },
            },
          },
        })
      )
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      apply_overrides('lackluster', overrides)
    end,
    opts = function()
      local lackluster = require('lackluster')
      local color = lackluster.color
      return {
        tweek_syntax = { comment = color.gray4 },
        tweek_background = { menu = color.gray3, popup = 'default' },
      }
    end,
  },
  {
    'wnkz/monoglow.nvim',
    cond = get_cond({ 'monoglow-z' }),
    priority = get_priority({ 'monoglow-z' }),
    event = get_event({ 'monoglow-z' }),
    init = function()
      local overrides = {
        { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.35 } } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
        {
          GitSignsAdd = {
            fg = { from = 'DiffAdd', attr = 'bg', alter = -0.15 },
          },
        },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptTitle = { bg = { from = 'SnacksPickerTitle' } } },
        { TelescopePromptBorder = { link = 'SnacksPickerBorder' } },
      })
      apply_overrides('monoglow-z', overrides)
    end,
  },
  {
    'aktersnurra/no-clown-fiesta.nvim',
    cond = get_cond({ 'no-clown-fiesta' }),
    priority = get_priority({ 'no-clown-fiesta' }),
    event = get_event({ 'no-clown-fiesta' }),
    opts = {},
  },
  {
    'dgox16/oldworld.nvim',
    cond = get_cond({ 'oldworld' }),
    priority = get_priority({ 'oldworld' }),
    event = get_event({ 'oldworld' }),
    init = function()
      local overrides = {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = 1.5 } } },
        { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg' } } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptTitle = { bg = { from = 'TelescopeTitle' } } },
        { TelescopePromptBorder = { link = 'SnacksPickerBorder' } },
      })
      apply_overrides('oldworld', overrides)
    end,
  },
  {
    'kvrohit/rasmus.nvim',
    cond = get_cond({ 'rasmus' }),
    priority = get_priority({ 'rasmus' }),
    event = get_event({ 'rasmus' }),
  },
  {
    'samharju/serene.nvim',
    cond = get_cond({ 'serene' }),
    priority = get_priority({ 'serene' }),
    event = get_event({ 'serene' }),
  },
  {
    'Wansmer/serenity.nvim',
    cond = get_cond({ 'serenity' }),
    priority = get_priority({ 'serenity' }),
    event = get_event({ 'serenity' }),
    opts = {},
  },
  {
    'dotsilas/darcubox-nvim',
    cond = get_cond({ 'darcubox' }),
    priority = get_priority({ 'darcubox' }),
    event = get_event({ 'darcubox' }),
  },
  {
    'https://git.sr.ht/~p00f/alabaster.nvim',
    cond = get_cond({ 'alabaster' }),
    priority = get_priority({ 'alabaster' }),
    event = get_event({ 'alabaster' }),
    init = function()
      apply_overrides('alabaster', {
        { WinSeparator = { fg = { from = 'NonText', alter = -0.4 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { fg = { from = 'VertSplit' } } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  {
    'masar3141/mono-jade',
    cond = get_cond({ 'mono-jade' }),
    priority = get_priority({ 'mono-jade' }),
    event = get_event({ 'mono-jade' }),
  },
  {
    'ferdinandrau/lavish.nvim',
    cond = get_cond({ 'lavish' }),
    priority = get_priority({ 'lavish' }),
    event = get_event({ 'lavish' }),
    -- config = function() require('lavish').apply() end,
  },
  {
    'comfysage/evergarden',
    cond = get_cond({ 'evergarden' }),
    priority = get_priority({ 'evergarden' }),
    event = get_event({ 'evergarden' }),
    opts = {
      transparent_background = true,
      variant = 'medium', -- 'hard'|'medium'|'soft'
      overrides = {},
    },
  },
  {
    'olivercederborg/poimandres.nvim',
    cond = get_cond({ 'poimandres' }), -- NOTE: clears highlighting on init
    priority = get_priority({ 'poimandres' }),
    event = get_event({ 'poimandres' }),
    opts = {},
  },
  {
    'Yazeed1s/oh-lucy.nvim',
    cond = get_cond({ 'oh-lucy', 'oh-lucy-evening' }),
    priority = get_priority({ 'oh-lucy', 'oh-lucy-evening' }),
    event = get_event({ 'oh-lucy', 'oh-lucy-evening' }),
  },
  {
    'mitch1000/backpack.nvim',
    cond = get_cond({ 'backpack' }),
    priority = get_priority({ 'backpack' }),
    event = get_event({ 'backpack' }),
    init = function()
      apply_overrides('backpack', {
        { Visual = { link = 'CursorLine' } },
        { Folded = { bg = { from = 'Folded', alter = 0.1 } } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }, true)
    end,
  },
  ------------------------------------------------------------------------------
  -- Mild
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    cond = get_cond({ 'rose-pine' }),
    priority = get_priority({ 'rose-pine' }),
    event = get_event({ 'rose-pine' }),
  },
  {
    -- NOTE: Double underlines markdown headings
    'oxfist/night-owl.nvim',
    priority = get_priority({ 'night-owl' }),
    event = get_event({ 'night-owl' }),
    cond = get_cond({ 'night-owl' }),
    -- opts = { underline = false },
  },
  {
    'atmosuwiryo/vim-winteriscoming',
    cond = get_cond({ 'WinterIsComing-dark-color-theme' }),
    priority = get_priority({ 'WinterIsComing-dark-color-theme' }),
    event = get_event({ 'WinterIsComing-dark-color-theme' }),
  },
  {
    'projekt0n/github-nvim-theme',
    cond = get_cond({ 'github_dark' }),
    priority = get_priority({ 'github_dark' }),
    event = get_event({ 'github_dark' }),
  },
  {
    'NTBBloodbath/doom-one.nvim',
    cond = get_cond({ 'doom-one' }),
    priority = get_priority({ 'doom-one' }),
    event = get_event({ 'doom-one' }),
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  {
    'neanias/everforest-nvim',
    cond = get_cond({ 'everforest' }),
    priority = get_priority({ 'everforest' }),
    event = get_event({ 'everforest' }),
    opts = {},
    config = function(_, opts) require('everforest').setup(opts) end,
  },
  {
    'nuvic/flexoki-nvim',
    name = 'flexoki',
    cond = get_cond({ 'flexoki' }),
    priority = get_priority({ 'flexoki' }),
    event = get_event({ 'flexoki' }),
    init = function()
      apply_overrides('flexoki', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.35 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
        { WhichKeyBorder = { link = 'FloatBorder' } },
      }, true)
    end,
  },
  {
    'aliqyan-21/darkvoid.nvim',
    cond = get_cond({ 'darkvoid' }),
    priority = get_priority({ 'darkvoid' }),
    event = get_event({ 'darkvoid' }),
  },
  {
    'lunarvim/lunar.nvim',
    cond = get_cond({ 'lunar' }),
    priority = get_priority({ 'lunar' }),
    event = get_event({ 'lunar' }),
    init = function()
      local overrides = {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { ColorColumn = { bg = { from = 'CursorLine', alter = 0.3 } } },
        { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
        { Todo = { link = 'Constant' } },
        { WinSeparator = { fg = { from = 'Comment', alter = -0.4 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
        { NeogitDiffAdd = { link = 'DiffAdd' } },
        { NeogitDiffDelete = { link = 'DiffDelete' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptTitle = { bg = { from = 'SnacksPickerTitle' } } },
        { TelescopePreviewTitle = { bg = { from = 'SnacksPickerTitle' } } },
      })
      apply_overrides('lunar', overrides)
    end,
  },
  {
    'philosofonusus/morta.nvim',
    name = 'morta',
    cond = get_cond({ 'morta' }),
    priority = get_priority({ 'morta' }),
    event = get_event({ 'morta' }),
    init = function()
      local overrides = {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'NonText' } },
        { NonText = { fg = { from = 'Comment', alter = -0.15 } } },
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.75 } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptTitle = { link = 'SnacksPickerTitle' } },
        { TelescopePromptTitle = { link = 'SnacksPickerTitle' } },
        { TelescopePreviewTitle = { link = 'SnacksPickerTitle' } },
        { TelescopeResultsTitle = { link = 'SnacksPickerTitle' } },
        { TelescopePromptNormal = { link = 'SnacksPicker' } },
        { TelescopePreviewNormal = { link = 'SnacksPicker' } },
        { TelescopeResultsNormal = { link = 'SnacksPicker' } },
        { TelescopePromptBorder = { link = 'SnacksPickerBorder' } },
        { TelescopePreviewBorder = { link = 'SnacksPickerBorder' } },
        { TelescopeResultsBorder = { link = 'SnacksPickerBorder' } },
      })
      apply_overrides('morta', overrides)
    end,
  },
  {
    'rjshkhr/shadow.nvim',
    cond = get_cond({ 'shadow' }),
    priority = get_priority({ 'shadow' }),
    event = get_event({ 'shadow' }),
  },
  {
    'RostislavArts/naysayer.nvim',
    cond = get_cond({ 'naysayer', 'naysayer.nvim' }),
    priority = get_priority({ 'naysayer' }),
    event = get_event({ 'naysayer' }),
  },
  {
    'jpwol/thorn.nvim',
    cond = get_cond({ 'thorn' }),
    priority = get_priority({ 'thorn' }),
    event = get_event({ 'thorn' }),
    init = function()
      local overrides = {
        { NonText = { link = 'Comment' } },
        { WinSeparator = { fg = { from = 'LineNr' } } },
        { VertSplit = { link = 'WinSeparator' } },
        { IndentBlanklineChar = { link = 'LineNr' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(overrides, generate_popup_overrides())
      ar.list_insert(overrides, generate_completion_overrides())
      ar.list_insert(overrides, generate_lsp_overrides())
      ar.list_insert(overrides, generate_picker_overrides())
      ar.list_insert(overrides, {
        { TelescopePromptTitle = { link = 'SnacksPickerTitle' } },
        { TelescopePromptBorder = { link = 'SnacksPickerBorder' } },
      })
      apply_overrides('thorn', overrides)
    end,
  },
  ------------------------------------------------------------------------------
  -- Clown show
  {
    'eldritch-theme/eldritch.nvim',
    cond = get_cond({ 'eldritch' }),
    priority = get_priority({ 'eldritch' }),
    event = get_event({ 'eldritch' }),
    opts = {},
  },
  {
    'judaew/ronny.nvim',
    cond = function() return colorscheme == 'ronny' end,
    priority = get_priority({ 'ronny' }),
    event = get_event({ 'ronny' }),
    opts = {},
  },
  {
    'LunarVim/horizon.nvim',
    cond = get_cond({ 'horizon' }),
    priority = get_priority({ 'horizon' }),
    event = get_event({ 'horizon' }),
  },
  {
    'scottmckendry/cyberdream.nvim',
    cond = get_cond({ 'cyberdream' }),
    priority = get_priority({ 'cyberdream' }),
    event = get_event({ 'cyberdream' }),
    opts = {},
  },
  {
    'folke/tokyonight.nvim',
    cond = get_cond({ 'tokyonight' }),
    priority = get_priority({ 'tokyonight' }),
    event = get_event({ 'tokyonight' }),
    opts = {},
  },
  {
    'wtfox/jellybeans.nvim',
    cond = get_cond({ 'jellybeans' }),
    priority = get_priority({ 'jellybeans' }),
    event = get_event({ 'jellybeans' }),
  },
  {
    'Skardyy/makurai-nvim',
    cond = get_cond({ 'makurai' }),
    priority = get_priority({ 'makurai' }),
    event = get_event({ 'makurai' }),
  },
  {
    'ribru17/bamboo.nvim',
    cond = get_cond({ 'bamboo' }),
    priority = get_priority({ 'bamboo' }),
    event = get_event({ 'bamboo' }),
  },
  -- }}}
}
