local scheme_switcher = require('ar.scheme_switcher')
local colorscheme = scheme_switcher.get_current_colorscheme()
local theming = require('ar.theming')
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
      ar.list_insert(overrides, theming.generate_completion_overrides())
      ar.list_insert(overrides, theming.generate_lsp_overrides())
      theming.apply_overrides('onedark', overrides)
    end,
  },
  ------------------------------------------------------------------------------
  -- Dark
  {
    'stefanvanburen/rams.vim',
    cond = get_cond({ 'rams' }),
    priority = get_priority({ 'rams' }),
    event = get_event({ 'rams' }),
    init = function()
      theming.apply_overrides('rams', {
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
          GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg', alter = 1.1 } },
        },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.6 } } },
      }, true)
    end,
  },
  {
    'kuri-sun/yoda.nvim',
    cond = get_cond({ 'yoda' }),
    priority = get_priority({ 'yoda' }),
    event = get_event({ 'yoda' }),
    init = function()
      theming.apply_overrides('yoda', {
        { CursorLine = { bg = { from = 'Normal', alter = 2.7 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.3 } } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.1 } } },
      }, true)
    end,
  },
  {
    'razak17/mapledark.nvim',
    cond = function() return colorscheme == 'mapledark' end,
    priority = get_priority({ 'mapledark' }),
    event = get_event({ 'mapledark' }),
    init = function()
      theming.apply_overrides('mapledark', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
      }, true)
    end,
    opts = { disable_plugin_highlights = false, plugins = { 'lazy' } },
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
      ar.list_insert(overrides, theming.generate_completion_overrides())
      ar.list_insert(overrides, theming.generate_lsp_overrides())
      theming.apply_overrides('vague', overrides)
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    cond = get_cond({ 'catppuccin' }),
    priority = get_priority({ 'catppuccin' }),
    event = get_event({ 'catppuccin' }),
    init = function()
      theming.apply_overrides('catppuccin', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = 2.2 } } },
      }, true)
    end,
  },
  {
    'biisal/blackhole',
    cond = get_cond({ 'blackhole' }),
    priority = get_priority({ 'blackhole' }),
    event = get_event({ 'blackhole' }),
    init = function()
      theming.apply_overrides('blackhole', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
      }, true)
    end,
  },
  {
    'bettervim/yugen.nvim',
    cond = get_cond({ 'yugen' }),
    priority = get_priority({ 'yugen' }),
    event = get_event({ 'yugen' }),
    init = function()
      theming.apply_overrides('yugen', {
        {
          WinSeparator = {
            bg = 'NONE',
            fg = { from = 'WinSeparator', alter = -0.1 },
          },
        },
        { WhichKeyBorder = { link = 'FloatBorder' } },
      }, true)
    end,
  },
  {
    'bluz71/vim-moonfly-colors',
    name = 'moonfly',
    cond = get_cond({ 'moonfly' }),
    priority = get_priority({ 'moonfly' }),
    event = get_event({ 'moonfly' }),
    init = function()
      theming.apply_overrides('moonfly', {
        {
          WinSeparator = {
            bg = 'NONE',
            fg = { from = 'WinSeparator', alter = -0.1 },
          },
        },
      }, true)
    end,
  },
  {
    'cooperuser/glowbeam.nvim',
    cond = get_cond({ 'glowbeam' }),
    priority = get_priority({ 'glowbeam' }),
    event = get_event({ 'glowbeam' }),
    init = function()
      theming.apply_overrides('glowbeam', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
      }, true)
    end,
  },
  {
    'danilo-augusto/vim-afterglow',
    cond = get_cond({ 'afterglow' }),
    priority = get_priority({ 'afterglow' }),
    event = get_event({ 'afterglow' }),
    init = function()
      theming.apply_overrides('afterglow', {
        {
          WinSeparator = {
            bg = 'NONE',
            fg = { from = 'WinSeparator', alter = -0.7 },
          },
        },
      }, true)
    end,
  },
  ------------------------------------------------------------------------------
  -- Warm
  {
    'alexkotusenko/nightgem.nvim',
    cond = get_cond({ 'nightgem' }),
    priority = get_priority({ 'nightgem' }),
    event = get_event({ 'nightgem' }),
    init = function()
      theming.apply_overrides('nightgem', {
        { CursorLine = { bg = { from = 'CursorLine', alter = -0.2 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
        {
          GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg', alter = 1.1 } },
        },
        { WinSeparator = { fg = { from = 'Comment' } } },
      }, true)
    end,
  },
  {
    'xeind/nightingale.nvim',
    cond = get_cond({ 'nightingale' }),
    priority = get_priority({ 'nightingale' }),
    event = get_event({ 'nightingale' }),
    init = function() theming.apply_overrides('nightingale', {}, true) end,
  },
  {
    'maccoda/irises.nvim',
    cond = get_cond({ 'irises' }),
    priority = get_priority({ 'irises' }),
    event = get_event({ 'irises' }),
    init = function()
      theming.apply_overrides('irises', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
      }, true)
    end,
  },
  {
    'savq/melange-nvim',
    cond = get_cond({ 'melange' }),
    priority = get_priority({ 'melange' }),
    event = get_event({ 'melange' }),
    init = function()
      theming.apply_overrides('melange', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
      }, true)
    end,
  },
  {
    'morhetz/gruvbox',
    cond = get_cond({ 'gruvbox' }),
    priority = get_priority({ 'gruvbox' }),
    event = get_event({ 'gruvbox' }),
    init = function()
      theming.apply_overrides('gruvbox', {
        { GruvboxRedSign = { bg = 'NONE' } },
        { GruvboxGreenSign = { bg = 'NONE' } },
        { GruvboxAquaSign = { bg = 'NONE' } },
        { Operator = { link = '@method' } },
        { ErrorMsg = { link = 'Error' } },
        {
          Visual = {
            bg = { from = 'Visual', alter = -0.25 },
            fg = 'NONE',
            reverse = false,
          },
        },
        { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
        { Dim = { link = 'WinSeparator' } },
        { WinSeparator = { bg = 'NONE', fg = { from = 'Dim', alter = -0.6 } } },
      }, true)
    end,
  },
  {
    'jnurmine/Zenburn',
    cond = get_cond({ 'zenburn' }),
    priority = get_priority({ 'zenburn' }),
    event = get_event({ 'zenburn' }),
    init = function()
      theming.apply_overrides('zenburn', {
        { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
        { Visual = { bg = { from = 'Visual', alter = 0.65 } } },
        { Dim = { link = 'Comment' } },
        { WinSeparator = { fg = { from = 'Dim', alter = -0.3 } } },
      }, true)
    end,
  },
  {
    'darianmorat/gruvdark.nvim',
    cond = get_cond({ 'gruvdark' }),
    priority = get_priority({ 'gruvdark' }),
    event = get_event({ 'gruvdark' }),
    init = function()
      theming.apply_overrides('gruvdark', {
        { Comment = { fg = { from = 'Comment', alter = 0.25 } } },
      }, true)
    end,
  },
  {
    'guillermodotn/nvim-earthsong',
    name = 'earthsong',
    cond = get_cond({ 'earthsong', 'earthsong-mute' }),
    priority = get_priority({ 'earthsong', 'earthsong-mute' }),
    event = get_event({ 'earthsong', 'earthsong-mute' }),
    init = function()
      theming.apply_overrides('earthsong-mute', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.2 } } },
        { WhichKeyBorder = { link = 'FloatBorder' } },
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
    init = function() theming.apply_overrides('kanso', {}, true) end,
  },
  {
    'zenbones-theme/zenbones.nvim',
    cond = get_cond({ 'zenbones' }),
    priority = get_priority({ 'zenbones' }),
    event = get_event({ 'zenbones' }),
    init = function()
      theming.apply_overrides('zenbones', {
        { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Folded = { bg = { from = 'Folded', alter = -0.2 } } },
        { WinSeparator = { fg = { from = 'VertSplit', alter = -0.35 } } },
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
      theming.apply_overrides('conifer', {
        { DiffAdd = { bg = { from = 'DiffAdd', alter = 3.15 } } },
        { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg' } } },
        { WinSeparator = { fg = { from = 'LineNr' } } },
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
      theming.apply_overrides('nanode', {
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
      }, true)
    end,
  },
  {
    'slugbyte/lackluster.nvim',
    cond = get_cond({ 'lackluster' }),
    priority = get_priority({ 'lackluster' }),
    event = get_event({ 'lackluster' }),
    init = function()
      theming.apply_overrides('lackluster', {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
        { Visual = { link = 'CursorLine' } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.4 } } },
      }, true)
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
    'dgox16/oldworld.nvim',
    cond = get_cond({ 'oldworld' }),
    priority = get_priority({ 'oldworld' }),
    event = get_event({ 'oldworld' }),
    init = function()
      theming.apply_overrides('oldworld', {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = 1.5 } } },
        { GitSignsAdd = { fg = { from = 'DiffAdd', attr = 'bg' } } },
      }, true)
    end,
  },
  {
    'https://git.sr.ht/~p00f/alabaster.nvim',
    cond = get_cond({ 'alabaster' }),
    priority = get_priority({ 'alabaster' }),
    event = get_event({ 'alabaster' }),
    init = function()
      theming.apply_overrides('alabaster', {
        { WinSeparator = { fg = { from = 'NonText', alter = -0.4 } } },
      }, true)
    end,
  },
  {
    'wnkz/monoglow.nvim',
    cond = get_cond({ 'monoglow-z' }),
    priority = get_priority({ 'monoglow-z' }),
    event = get_event({ 'monoglow-z' }),
    init = function()
      theming.apply_overrides('monoglow-z', {
        { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.35 } } },
        { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
        {
          GitSignsAdd = {
            fg = { from = 'DiffAdd', attr = 'bg', alter = -0.15 },
          },
        },
      }, true)
    end,
  },
  {
    'mitch1000/backpack.nvim',
    cond = get_cond({ 'backpack' }),
    priority = get_priority({ 'backpack' }),
    event = get_event({ 'backpack' }),
    init = function()
      theming.apply_overrides('backpack', {
        { Visual = { link = 'CursorLine' } },
        { Folded = { bg = { from = 'Folded', alter = 0.1 } } },
      }, true)
    end,
  },
  {
    'olivercederborg/poimandres.nvim',
    cond = get_cond({ 'poimandres' }), -- NOTE: clears highlighting on init
    priority = get_priority({ 'poimandres' }),
    event = get_event({ 'poimandres' }),
    init = function()
      theming.apply_overrides('poimandres', {
        { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.55 } } },
        { Folded = { bg = { from = 'Folded', alter = 0.7 } } },
        { Visual = { bg = { from = 'Visual', alter = -0.25 }, fg = 'NONE' } },
        { Dim = { inherit = 'WinSeparator' } },
        { WinSeparator = { bg = 'NONE', fg = { from = 'Dim', alter = -0.7 } } },
        { NeogitDiffAdd = { link = 'DiffAdd' } },
        { NeogitDiffDelete = { link = 'DiffDelete' } },
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
    'aktersnurra/no-clown-fiesta.nvim',
    cond = get_cond({ 'no-clown-fiesta' }),
    priority = get_priority({ 'no-clown-fiesta' }),
    event = get_event({ 'no-clown-fiesta' }),
    opts = {},
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
    'Yazeed1s/oh-lucy.nvim',
    cond = get_cond({ 'oh-lucy', 'oh-lucy-evening' }),
    priority = get_priority({ 'oh-lucy', 'oh-lucy-evening' }),
    event = get_event({ 'oh-lucy', 'oh-lucy-evening' }),
  },
  ------------------------------------------------------------------------------
  -- Mild
  {
    'nuvic/flexoki-nvim',
    name = 'flexoki',
    cond = get_cond({ 'flexoki' }),
    priority = get_priority({ 'flexoki' }),
    event = get_event({ 'flexoki' }),
    init = function()
      theming.apply_overrides('flexoki', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.35 } } },
        { WhichKeyBorder = { link = 'FloatBorder' } },
      }, true)
    end,
  },
  {
    'lunarvim/lunar.nvim',
    cond = get_cond({ 'lunar' }),
    priority = get_priority({ 'lunar' }),
    event = get_event({ 'lunar' }),
    init = function()
      theming.apply_overrides('lunar', {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'LineNr' } },
        { ColorColumn = { bg = { from = 'CursorLine', alter = 0.3 } } },
        { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
        { Todo = { link = 'Constant' } },
        { WinSeparator = { fg = { from = 'Comment', alter = -0.4 } } },
        {
          NeogitDiffAdd = {
            bg = { from = 'DiffAdd', alter = 1.4 },
            fg = { from = 'DiffAdd', attr = 'bg', alter = -0.65 },
            reverse = true,
          },
        },
        { NeogitDiffDelete = { link = 'DiffDelete' } },
      }, true)
    end,
  },
  {
    'philosofonusus/morta.nvim',
    name = 'morta',
    cond = get_cond({ 'morta' }),
    priority = get_priority({ 'morta' }),
    event = get_event({ 'morta' }),
    init = function()
      theming.apply_overrides('morta', {
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'NonText' } },
        { NonText = { fg = { from = 'Comment', alter = -0.15 } } },
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.75 } } },
      }, true)
    end,
  },
  {
    'jpwol/thorn.nvim',
    cond = get_cond({ 'thorn' }),
    priority = get_priority({ 'thorn' }),
    event = get_event({ 'thorn' }),
    init = function()
      theming.apply_overrides('thorn', {
        { NonText = { link = 'Comment' } },
        { WinSeparator = { fg = { from = 'LineNr' } } },
      }, true)
    end,
  },
  {
    'rakr/vim-two-firewatch',
    cond = get_cond({ 'two-firewatch' }),
    priority = get_priority({ 'two-firewatch' }),
    event = get_event({ 'two-firewatch' }),
    init = function()
      theming.apply_overrides('two-firewatch', {
        { Folded = { bg = { from = 'Folded', alter = -0.35 } } },
        { Visual = { bg = { from = 'CursorLine', alter = 0.3 } } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.3 } } },
      }, true)
    end,
  },
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
    'aliqyan-21/darkvoid.nvim',
    cond = get_cond({ 'darkvoid' }),
    priority = get_priority({ 'darkvoid' }),
    event = get_event({ 'darkvoid' }),
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
    'edeneast/nightfox.nvim',
    cond = get_cond({ 'nightfox' }),
    priority = get_priority({ 'nightfox' }),
    event = get_event({ 'nightfox' }),
  },
  {
    'rebelot/kanagawa.nvim',
    cond = get_cond({ 'kanagawa' }),
    priority = get_priority({ 'kanagawa' }),
    event = get_event({ 'kanagawa' }),
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
