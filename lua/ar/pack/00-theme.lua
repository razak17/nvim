local scheme_switcher = require('ar.scheme_switcher')
local colorscheme = scheme_switcher.get_current_colorscheme()
local theming = require('ar.theming')

--- Get colorscheme cond
---@param names table
---@return boolean
local function get_cond(names)
  if ar.config.colorscheme.all or vim.list_contains(names, colorscheme) then
    return true
  end
  return not ar.plugins.minimal and vim.tbl_contains(names, colorscheme)
end

ar.pack.add({
  {
    src = 'https://github.com/razak17/onedark.nvim',
    cond = get_cond({ 'onedark' }),
    dev = true,
    lazy = false,
    setup = function()
      require('onedark').setup({ variant = ar.config.colorscheme.variant })
      local overrides = {
        { Strict = { link = 'DiffDeleteAlt' } },
        { Dim = { link = 'VertSplit' } },
        -- { ['@variable'] = { fg = { from = '@none' } } },
      }
      ar.list_insert(
        overrides,
        theming.generate_completion_overrides(),
        theming.generate_lsp_overrides()
      )
      theming.apply_overrides('onedark', { default = overrides })
    end,
  },
  {
    src = 'https://github.com/voylin/godot_color_theme',
    lazy = false,
    cond = get_cond({ 'godot' }),
    init = function()
      theming.apply_overrides('godot', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/oskarnurm/koda.nvim',
    lazy = false,
    cond = get_cond({ 'koda' }),
    init = function()
      theming.apply_overrides('koda', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.75 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Perljak/terracotta.nvim',
    lazy = false,
    cond = get_cond({ 'terracotta' }),
    init = function()
      theming.apply_overrides('terracotta', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
    setup = function()
      require('terracotta').setup({
        transparent = ar.config.ui.transparent.enable,
      })
    end,
  },
  {
    src = 'https://codeberg.org/juanmilkah/anticuus.nvim',
    lazy = false,
    cond = get_cond({ 'anticuus' }),
    init = function()
      theming.apply_overrides('anticuus', {
        default = {
          { Added = { fg = { from = 'Added', alter = -0.45 } } },
          { Changed = { fg = { from = 'Changed', alter = -0.15 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/valonmulolli/heap.nvim',
    lazy = false,
    cond = function()
      return vim.tbl_contains({ 'heap', 'heap-dark' }, colorscheme)
    end,
    init = function()
      theming.apply_overrides('heap-dark', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 4.5 } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = -0.45 } } },
          { GitSignsChange = { fg = { from = 'Changed', alter = -0.2 } } },
        },
      }, true)
    end,
    setup = function()
      require('heap').setup({
        variant = 'dark', -- "default" or "dark"
        transparent = false,
      })
    end,
  },
  {
    src = 'https://github.com/stefanvanburen/rams.vim',
    lazy = false,
    cond = get_cond({ 'rams' }),
    init = function()
      theming.apply_overrides('rams', {
        default = {
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
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.6 } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = -0.35 } } },
          { GitSignsChange = { fg = { from = 'Changed', alter = -0.15 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/kuri-sun/yoda.nvim',
    lazy = false,
    cond = get_cond({ 'yoda' }),
    init = function()
      theming.apply_overrides('yoda', {
        default = {
          { CursorLine = { bg = { from = 'Normal', alter = 2.7 } } },
          { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
          { Visual = { bg = { from = 'CursorLine', alter = 0.3 } } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/razak17/mapledark.nvim',
    lazy = false,
    cond = function() return colorscheme == 'mapledark' end,
    init = function()
      theming.apply_overrides('mapledark', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        },
      }, true)
    end,
    setup = function()
      require('mapledark').setup({
        disable_plugin_highlights = false,
        plugins = { 'lazy' },
      })
    end,
  },
  {
    src = 'https://github.com/catppuccin/nvim',
    lazy = false,
    name = 'catppuccin',
    cond = get_cond({ 'catppuccin' }),
    init = function()
      theming.apply_overrides('catppuccin', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 2.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/biisal/blackhole',
    lazy = false,
    cond = get_cond({ 'blackhole' }),
    init = function()
      theming.apply_overrides('blackhole', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/bettervim/yugen.nvim',
    lazy = false,
    cond = get_cond({ 'yugen' }),
    init = function()
      theming.apply_overrides('yugen', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
        plugin = {
          { WhichKeyBorder = { link = 'FloatBorder' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/bluz71/vim-moonfly-colors',
    lazy = false,
    name = 'moonfly',
    cond = get_cond({ 'moonfly' }),
    init = function()
      theming.apply_overrides('moonfly', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/cooperuser/glowbeam.nvim',
    lazy = false,
    cond = get_cond({ 'glowbeam' }),
    init = function()
      theming.apply_overrides('glowbeam', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/danilo-augusto/vim-afterglow',
    lazy = false,
    cond = get_cond({ 'afterglow' }),
    init = function()
      theming.apply_overrides('afterglow', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/nikolvs/vim-sunbather',
    lazy = false,
    cond = get_cond({ 'sunbather' }),
    init = function()
      theming.apply_overrides('sunbather', {
        default = {
          {
            Visual = { bg = { from = 'Visual', alter = -0.7 }, fg = 'NONE' },
          },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ferrissushi/ferriouscolor.nvim',
    lazy = false,
    cond = get_cond({ 'ferriouscolor' }),
    init = function()
      theming.apply_overrides('ferriouscolor', {
        default = {
          { Visual = { bg = { from = 'Visual', alter = -0.4 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Kaikacy/Lemons.nvim',
    lazy = false,
    version = vim.version.range('*'),
    cond = get_cond({ 'lemons' }),
    init = function()
      theming.apply_overrides('lemons', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.15 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/wtfox/jellybeans.nvim',
    lazy = false,
    cond = get_cond({ 'jellybeans', 'jellybeans-warm' }),
    init = function()
      theming.apply_overrides({
        'jellybeans',
        'jellybeans-warm',
      }, {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.35 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Skardyy/makurai-nvim',
    lazy = false,
    cond = get_cond({ 'makurai_dark' }),
    init = function()
      theming.apply_overrides('makurai_dark', {
        { CursorLine = { bg = { from = 'CursorLine', alter = 0.25 } } },
        { Folded = { bg = { from = 'CursorLine', alter = 0.25 } } },
        { WinSeparator = { fg = { from = 'LineNr', alter = -0.05 } } },
      }, true)
    end,
  },
  {
    src = 'https://github.com/scottmckendry/cyberdream.nvim',
    lazy = false,
    cond = get_cond({ 'cyberdream' }),
    init = function()
      theming.apply_overrides('cyberdream', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = -0.25 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
    setup = function() require('cyberdream').setup() end,
  },
  {
    src = 'https://github.com/uhs-robert/oasis.nvim',
    lazy = false,
    cond = get_cond({ 'oasis' }),
    init = function()
      theming.apply_overrides('oasis', {
        default = {
          -- { Folded = { bg = { from = 'Folded', alter = -0.1 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        },
      }, true)
    end,
    setup = function() require('oasis').setup() end,
  },
  {
    src = 'https://github.com/adibhanna/yukinord.nvim',
    lazy = false,
    cond = get_cond({ 'yukinord' }),
    init = function()
      theming.apply_overrides('yukinord', {
        default = {
          { DiagnosticVirtualTextInfo = { bg = 'NONE' } },
          { DiagnosticVirtualTextHint = { bg = 'NONE' } },
          { DiagnosticVirtualTextWarn = { bg = 'NONE' } },
          { DiagnosticVirtualTextError = { bg = 'NONE' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/chaserensberger/christmas.nvim',
    lazy = false,
    cond = get_cond({ 'christmas' }),
    init = function()
      theming.apply_overrides('christmas', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.6 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/nyoom-engineering/oxocarbon.nvim',
    lazy = false,
    cond = get_cond({ 'oxocarbon' }),
    init = function()
      theming.apply_overrides('oxocarbon', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/the-coding-doggo/batman.nvim',
    lazy = false,
    cond = function() return colorscheme == 'batman' end,
    init = function()
      ar.add_to_select('command_palette', {
        ['Batman Colors'] = require('ar.batman_scheme_switcher').colorscheme_menu,
      })
      theming.apply_overrides('batman', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.45 } },
          },
        },
      }, true)
    end,
    setup = function()
      require('batman').setup({ theme = 'catwoman', use_persistence = false })
    end,
  },
  {
    src = 'https://github.com/nendix/zen.nvim',
    lazy = false,
    cond = get_cond({ 'zen' }),
    init = function()
      theming.apply_overrides('zen', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.45 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Pair-of-dice/Alienocean.nvim',
    lazy = false,
    cond = get_cond({ 'Alienocean' }),
    init = function()
      theming.apply_overrides('Alienocean', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
        plugin = {
          { WhichKeyBorder = { link = 'FloatBorder' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/3dyuval/retro-fallout.nvim',
    lazy = false,
    cond = get_cond({ 'retro-fallout' }),
    init = function()
      theming.apply_overrides('retro-fallout', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.5 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ZzurabSiprashvili/monokai-night.nvim',
    lazy = false,
    cond = get_cond({ 'monokai-night' }),
    init = function()
      theming.apply_overrides('monokai-night', {
        default = {
          { WinSeparator = { fg = { from = 'NonText', alter = -0.6 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/0x-ximon/acario.nvim',
    lazy = false,
    cond = get_cond({ 'acario_dark', 'acario_light' }),
    init = function()
      theming.apply_overrides('acario_dark', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.2 } } },
        },
        popup = {
          { FloatTitle = { fg = { from = 'Variable' } } },
        },
      }, true)
      theming.apply_overrides('acario_light', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.5 } } },
          { StatusLine = { bg = 'NONE' } },
        },
        popup = {
          { FloatTitle = { bg = { from = 'Normal', alter = -0.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/thekylehuang/cole.nvim',
    lazy = false,
    cond = get_cond({ 'cole' }),
    init = function()
      theming.apply_overrides('cole', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ryovoid/dracula-night',
    lazy = false,
    cond = get_cond({ 'dracula-night' }),
    init = function()
      theming.apply_overrides('dracula-night', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.8 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/g-kirti/hardhat.nvim',
    lazy = false,
    cond = get_cond({ 'hardhat', 'hardhat-vivid' }),
    init = function()
      theming.apply_overrides('hardhat', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.8 } } },
        },
      }, true)
      theming.apply_overrides('hardhat-vivid', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 3.5 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/dgrco/deepwater.nvim',
    lazy = false,
    cond = get_cond({ 'deepwater' }),
    init = function()
      theming.apply_overrides('deepwater', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/alexkotusenko/nightgem.nvim',
    lazy = false,
    cond = get_cond({ 'nightgem' }),
    init = function()
      theming.apply_overrides('nightgem', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = -0.2 } } },
          { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
          { Visual = { bg = { from = 'CursorLine', alter = 0.1 } } },
          { Added = { fg = { from = 'Added', alter = -0.45 } } },
          { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
          {
            DiffChange = {
              bg = { from = 'Changed', attr = 'fg', alter = -0.35 },
            },
          },
          { WinSeparator = { fg = { from = 'Comment' } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/xeind/nightingale.nvim',
    lazy = false,
    cond = get_cond({ 'nightingale' }),
    init = function() theming.apply_overrides('nightingale', {}, true) end,
  },
  {
    src = 'https://github.com/maccoda/irises.nvim',
    lazy = false,
    cond = get_cond({ 'irises' }),
    init = function()
      theming.apply_overrides('irises', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/savq/melange-nvim',
    lazy = false,
    cond = get_cond({ 'melange' }),
    init = function()
      theming.apply_overrides('melange', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/dybdeskarphet/gruvbox-minimal.nvim',
    lazy = false,
    cond = get_cond({ 'gruvbox-minimal' }),
    init = function()
      theming.apply_overrides('gruvbox-minimal', {
        default = {
          { Visual = { bg = { from = 'Visual', alter = -0.3 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/jnurmine/Zenburn',
    lazy = false,
    cond = get_cond({ 'zenburn' }),
    init = function()
      theming.apply_overrides('zenburn', {
        default = {
          { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
          { Visual = { bg = { from = 'Visual', alter = 0.65 } } },
          { Dim = { link = 'Comment' } },
          { WinSeparator = { fg = { from = 'Dim', alter = -0.3 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/darianmorat/gruvdark.nvim',
    lazy = false,
    cond = get_cond({ 'gruvdark' }),
    init = function()
      theming.apply_overrides('gruvdark', {
        default = {
          { Comment = { fg = { from = 'Comment', alter = 0.25 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/guillermodotn/nvim-earthsong',
    lazy = false,
    name = 'earthsong',
    cond = get_cond({ 'earthsong', 'earthsong-mute' }),
    init = function()
      theming.apply_overrides('earthsong-mute', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.2 } } },
        },
        plugin = {
          { WhichKeyBorder = { link = 'FloatBorder' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/webhooked/kanso.nvim',
    lazy = false,
    cond = get_cond({ 'kanso' }),
    init = function() theming.apply_overrides('kanso', {}, true) end,
  },
  {
    src = 'https://github.com/zenbones-theme/zenbones.nvim',
    lazy = false,
    cond = get_cond({
      'duckbones',
      'forestbones',
      'kanagawabones',
      'neobones',
      'nordbones',
      'randombones',
      'randombones_dark',
      'randombones_light',
      'rosebones',
      'seoulbones',
      'tokyobones',
      'vimbones',
      'zenbones',
      'zenburned',
      'zenwritten',
    }),
    init = function()
      theming.apply_overrides({
        'duckbones',
        'forestbones',
        'kanagawabones',
        'neobones',
        'nordbones',
        'randombones',
        'randombones_dark',
        'rosebones',
        'seoulbones',
        'tokyobones',
        'zenbones',
        'zenburned',
        'zenwritten',
      }, {
        default = {
          { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.4 } } },
          { Folded = { bg = { from = 'Folded', alter = -0.2 } } },
          { WinSeparator = { fg = { from = 'VertSplit', alter = -0.35 } } },
        },
      }, true)
    end,
    dependencies = { { src = 'https://github.com/rktjmp/lush.nvim' } },
  },
  {
    src = 'https://github.com/lucasadelino/conifer.nvim',
    lazy = false,
    cond = get_cond({ 'conifer' }),
    init = function()
      theming.apply_overrides('conifer', {
        default = {
          { DiffAdd = { bg = { from = 'DiffAdd', alter = 2.45 } } },
          { DiffChange = { bg = { from = 'DiffChange', alter = 2.45 } } },
          { WinSeparator = { fg = { from = 'LineNr' } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = -0.35 } } },
          { GitSignsChange = { fg = { from = 'Changed', alter = -0.45 } } },
        },
      }, true)
    end,
    setup = function()
      require('conifer').setup({ transparent = ar.config.ui.transparent.enable })
    end,
  },
  {
    src = 'https://github.com/KijitoraFinch/nanode.nvim',
    lazy = false,
    cond = function() return colorscheme == 'nanode' end,
    init = function()
      theming.apply_overrides('nanode', {
        default = {
          { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.2 } } },
          { Comment = { fg = { from = 'Comment', alter = -0.3 } } },
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.8 } } },
          { CursorLineNr = { link = 'String' } },
          { LineNr = { fg = { from = 'LineNr', alter = -0.3 } } },
          {
            Visual = { bg = { from = 'Visual', alter = -0.6 }, fg = 'NONE' },
          },
          { Dim = { fg = { from = 'Comment', alter = -0.3 } } },
          { NonText = { fg = { from = 'NonText', alter = 0.3 } } },
          { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.4 } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = -0.35 } } },
          { GitSignsChange = { fg = { from = 'Changed', alter = -0.15 } } },
        },
      }, true)
    end,
    setup = function()
      require('nanode').setup({ transparent = ar.config.ui.transparent.enable })
    end,
  },
  {
    src = 'https://github.com/slugbyte/lackluster.nvim',
    lazy = false,
    cond = get_cond({ 'lackluster' }),
    init = function()
      theming.apply_overrides('lackluster', {
        default = {
          { Winbar = { link = 'Variable' } },
          { WinbarNC = { link = 'LineNr' } },
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.2 } } },
          { Folded = { bg = { from = 'CursorLine', alter = 0.2 } } },
          { Visual = { link = 'CursorLine' } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.4 } } },
        },
      }, true)
    end,
    setup = function()
      local color = require('lackluster').color
      require('lackluster').setup({
        tweek_syntax = { comment = color.gray4 },
        tweek_background = { menu = color.gray3, popup = 'default' },
      })
    end,
  },
  {
    src = 'https://github.com/dgox16/oldworld.nvim',
    lazy = false,
    cond = get_cond({ 'oldworld' }),
    init = function()
      theming.apply_overrides('oldworld', {
        default = {
          { Winbar = { link = 'Variable' } },
          { WinbarNC = { link = 'LineNr' } },
          { DiffAdd = { bg = { from = 'DiffAdd', alter = 1.5 } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = -0.45 } } },
          { GitSignsChange = { fg = { from = 'Changed', alter = -0.25 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://git.sr.ht/~p00f/alabaster.nvim',
    lazy = false,
    cond = get_cond({ 'alabaster' }),
    init = function()
      theming.apply_overrides('alabaster', {
        default = {
          { WinSeparator = { fg = { from = 'NonText', alter = -0.4 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/wnkz/monoglow.nvim',
    lazy = false,
    cond = get_cond({ 'monoglow-z' }),
    init = function()
      theming.apply_overrides('monoglow-z', {
        default = {
          { Folded = { bg = { from = 'CursorLine', alter = 0.1 } } },
          { Visual = { bg = { from = 'CursorLine', alter = 0.35 } } },
          { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.15 } } },
        },
        plugin = {
          { GitSignsAdd = { fg = { from = 'Added', alter = 0.05 } } },
          {
            GitSignsChange = { fg = { from = 'Changed', alter = -0.05 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/mitch1000/backpack.nvim',
    lazy = false,
    cond = get_cond({ 'backpack' }),
    init = function()
      theming.apply_overrides('backpack', {
        default = {
          { Visual = { link = 'CursorLine' } },
          { Folded = { bg = { from = 'Folded', alter = 0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/olivercederborg/poimandres.nvim',
    lazy = false,
    cond = get_cond({ 'poimandres' }),
    init = function()
      theming.apply_overrides('poimandres', {
        default = {
          { ColorColumn = { bg = { from = 'ColorColumn', alter = -0.55 } } },
          { Folded = { bg = { from = 'Folded', alter = 0.7 } } },
          {
            Visual = { bg = { from = 'Visual', alter = -0.25 }, fg = 'NONE' },
          },
          { Dim = { inherit = 'WinSeparator' } },
          { DiffAdd = { bg = { from = 'DiffAdd', alter = -0.55 } } },
          { DiffChange = { bg = { from = 'DiffChange', alter = -0.45 } } },
          { DiffDelete = { bg = { from = 'DiffDelete', alter = -0.25 } } },
          { WinSeparator = { fg = { from = 'Dim', alter = -0.7 } } },
        },
        plugin = {
          {
            GitSignsAdd = {
              fg = { from = 'DiffAdd', attr = 'bg', alter = 1.6 },
            },
          },
          { NeogitDiffAdd = { link = 'DiffAdd' } },
          { NeogitDiffDelete = { link = 'DiffDelete' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/stevedylandev/darkmatter-nvim',
    lazy = false,
    cond = get_cond({ 'darkmatter' }),
    init = function()
      theming.apply_overrides('darkmatter', {
        default = {
          { LineNr = { fg = { from = 'LineNr', alter = -0.25 } } },
          { Comment = { fg = { from = 'Comment', alter = 0.45 } } },
          { NonText = { link = 'Comment' } },
          { Dim = { link = 'Comment' } },
          { CursorLineNr = { link = 'TSString' } },
          { WinSeparator = { fg = { from = 'Dim', alter = -0.35 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ficcdaf/ashen.nvim',
    lazy = false,
    cond = get_cond({ 'ashen' }),
    init = function()
      theming.apply_overrides('ashen', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/aktersnurra/no-clown-fiesta.nvim',
    lazy = false,
    cond = get_cond({ 'no-clown-fiesta' }),
    init = function()
      theming.apply_overrides('no-clown-fiesta', {
        { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.45 } } },
      }, true)
    end,
    setup = function() require('no-clown-fiesta').setup() end,
  },
  {
    src = 'https://github.com/kvrohit/rasmus.nvim',
    lazy = false,
    cond = get_cond({ 'rasmus' }),
    init = function()
      theming.apply_overrides('rasmus', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.65 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/samharju/serene.nvim',
    lazy = false,
    cond = get_cond({ 'serene' }),
    init = function()
      theming.apply_overrides('serene', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.35 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Wansmer/serenity.nvim',
    lazy = false,
    cond = get_cond({ 'serenity' }),
    init = function() theming.apply_overrides('serenity', {}, true) end,
    setup = function() require('serenity').setup() end,
  },
  {
    src = 'https://github.com/dotsilas/darcubox-nvim',
    lazy = false,
    cond = get_cond({ 'darcubox' }),
    init = function()
      theming.apply_overrides('darcubox', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.25 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/masar3141/mono-jade',
    lazy = false,
    cond = get_cond({ 'mono-jade' }),
    init = function()
      theming.apply_overrides('mono-jade', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = -0.45 } } },
          { Visual = { bg = { from = 'Visual', alter = -0.25 } } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.35 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ferdinandrau/lavish.nvim',
    lazy = false,
    cond = get_cond({ 'lavish' }),
    init = function()
      theming.apply_overrides('lavish', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.15 } } },
          {
            Visual = {
              bg = { from = 'Visual', alter = -0.25 },
              fg = 'NONE',
            },
          },
          { NonText = { fg = { from = 'NonText', alter = 1.4 } } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/comfysage/evergarden',
    lazy = false,
    cond = get_cond({ 'evergarden' }),
    init = function()
      theming.apply_overrides('evergarden', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.1 } } },
        },
      }, true)
    end,
    setup = function()
      require('evergarden').setup({
        transparent_background = true,
        variant = 'medium', -- 'hard'|'medium'|'soft'
        overrides = {},
      })
    end,
  },
  {
    src = 'https://github.com/Yazeed1s/oh-lucy.nvim',
    lazy = false,
    cond = get_cond({ 'oh-lucy', 'oh-lucy-evening' }),
    init = function()
      theming.apply_overrides('oh-lucy', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.25 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/cdmill/neomodern.nvim',
    lazy = false,
    cond = get_cond({ 'iceclimber', 'gyokuro', 'hojicha', 'roseprime' }),
    init = function()
      theming.apply_overrides('iceclimber', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.25 } },
          },
        },
      }, true)
    end,
    setup = function()
      require('neomodern').setup({ theme = 'iceclimber', variant = 'dark' })
    end,
  },
  {
    src = 'https://github.com/silentium-theme/silentium.nvim',
    lazy = false,
    cond = get_cond({ 'silentium' }),
    init = function()
      theming.apply_overrides('silentium', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/vossenwout/guts.nvim',
    lazy = false,
    cond = get_cond({ 'guts' }),
    init = function()
      theming.apply_overrides('guts', {
        default = {
          { CursorLine = { bg = { from = 'CursorColumn' } } },
          { Visual = { bg = { from = 'CursorColumn', alter = 0.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/micdzu/aalto.nvim',
    lazy = false,
    cond = get_cond({ 'aalto' }),
    init = function()
      theming.apply_overrides('aalto', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.45 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/nuvic/flexoki-nvim',
    lazy = false,
    name = 'flexoki',
    cond = get_cond({ 'flexoki' }),
    init = function()
      theming.apply_overrides('flexoki', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.35 } },
          },
        },
        plugin = {
          { WhichKeyBorder = { link = 'FloatBorder' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/lunarvim/lunar.nvim',
    lazy = false,
    cond = get_cond({ 'lunar' }),
    init = function()
      theming.apply_overrides('lunar', {
        default = {
          { Winbar = { link = 'Variable' } },
          { WinbarNC = { link = 'LineNr' } },
          { ColorColumn = { bg = { from = 'CursorLine', alter = 0.3 } } },
          { Folded = { bg = { from = 'CursorLine', alter = -0.1 } } },
          { Todo = { link = 'Constant' } },
          { WinSeparator = { fg = { from = 'Comment', alter = -0.4 } } },
        },
        plugin = {
          {
            NeogitDiffAdd = {
              bg = { from = 'DiffAdd', alter = 1.4 },
              fg = { from = 'DiffAdd', attr = 'bg', alter = -0.65 },
              reverse = true,
            },
          },
          { NeogitDiffDelete = { link = 'DiffDelete' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/philosofonusus/morta.nvim',
    lazy = false,
    name = 'morta',
    cond = get_cond({ 'morta' }),
    init = function()
      theming.apply_overrides('morta', {
        default = {
          { Winbar = { link = 'Variable' } },
          { WinbarNC = { link = 'NonText' } },
          { NonText = { fg = { from = 'Comment', alter = -0.15 } } },
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.75 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/jpwol/thorn.nvim',
    lazy = false,
    cond = get_cond({ 'thorn' }),
    init = function()
      theming.apply_overrides('thorn', {
        default = {
          { NonText = { link = 'Comment' } },
          { WinSeparator = { fg = { from = 'LineNr' } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/rakr/vim-two-firewatch',
    lazy = false,
    cond = get_cond({ 'two-firewatch' }),
    init = function()
      theming.apply_overrides('two-firewatch', {
        default = {
          { Folded = { bg = { from = 'Folded', alter = -0.35 } } },
          { Visual = { bg = { from = 'CursorLine', alter = 0.3 } } },
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.3 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/rose-pine/neovim',
    lazy = false,
    name = 'rose-pine',
    cond = get_cond({ 'rose-pine' }),
    init = function()
      theming.apply_overrides('rose-pine', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.45 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/oxfist/night-owl.nvim',
    lazy = false,
    cond = get_cond({ 'night-owl' }),
    init = function()
      theming.apply_overrides('night-owl', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.95 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 0.45 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/projekt0n/github-nvim-theme',
    lazy = false,
    cond = get_cond({ 'github_dark_dimmed', 'github_dark_tritanopia' }),
    init = function()
      theming.apply_overrides('github_dark_dimmed', {
        default = {
          { Folded = { bg = { from = 'Folded', alter = 0.1 } } },
          { Type = { fg = { from = 'Type', alter = -0.25 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 0.1 } } },
        },
      }, true)
      theming.apply_overrides('github_dark_tritanopia', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = -0.3 } } },
          { Folded = { bg = { from = 'Folded', alter = 0.2 } } },
          { Type = { fg = { from = 'Type', alter = -0.45 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 0.3 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/NTBBloodbath/doom-one.nvim',
    lazy = false,
    cond = get_cond({ 'doom-one' }),
    init = function()
      theming.apply_overrides('doom-one', {
        default = {
          { CursorLine = { bg = { from = 'CursorLine', alter = 0.05 } } },
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.65 } },
          },
        },
      }, true)
    end,
    setup = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  {
    src = 'https://github.com/neanias/everforest-nvim',
    lazy = false,
    cond = get_cond({ 'everforest' }),
    init = function()
      theming.apply_overrides('everforest', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.2 } } },
        },
      }, true)
    end,
    setup = function() require('everforest').setup() end,
  },
  {
    src = 'https://github.com/aliqyan-21/darkvoid.nvim',
    lazy = false,
    cond = get_cond({ 'darkvoid' }),
    init = function()
      theming.apply_overrides('darkvoid', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.65 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/rjshkhr/shadow.nvim',
    lazy = false,
    cond = get_cond({ 'shadow' }),
    init = function()
      theming.apply_overrides('shadow', {
        default = {
          { Folded = { bg = { from = 'Folded', alter = 2.65 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 0.45 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/RostislavArts/naysayer.nvim',
    lazy = false,
    cond = get_cond({ 'naysayer' }),
    init = function()
      theming.apply_overrides('naysayer', {
        default = {
          { Folded = { bg = { from = 'CursorLine', alter = 0.15 } } },
          {
            Visual = {
              fg = 'NONE',
              bg = { from = 'CursorLine', alter = 0.45 },
            },
          },
          { MatchParen = { link = 'Visual' } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.6 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/tommarien/github-plus.nvim',
    lazy = false,
    cond = get_cond({ 'github_plus' }),
    init = function()
      theming.apply_overrides('github_plus', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.2 } } },
        },
        plugin = {
          { TreesitterContextBottom = { underline = false } },
        },
      }, true)
    end,
    setup = function() require('github-plus').setup() end,
  },
  {
    src = 'https://github.com/AlexvZyl/nordic.nvim',
    lazy = false,
    cond = get_cond({ 'nordic' }),
    init = function()
      theming.apply_overrides('nordic', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.5 } } },
        },
      }, true)
    end,
    setup = function()
      if colorscheme == 'nordic' then require('nordic').load() end
    end,
  },
  {
    src = 'https://github.com/shaunsingh/nord.nvim',
    lazy = false,
    cond = get_cond({ 'nord' }),
    init = function()
      theming.apply_overrides('nord', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.2 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/xero/evangelion.nvim',
    lazy = false,
    cond = get_cond({ 'evangelion' }),
    init = function()
      theming.apply_overrides('evangelion', {
        default = {
          { Comment = { bg = 'NONE' } },
          { SpellBad = { link = 'Comment' } },
          { Directory = { bg = 'NONE' } },
          { LineNr = { fg = { from = 'CursorLineNr', alter = -0.55 } } },
          {
            Folded = {
              bg = { from = 'CursorLine', alter = -0.1 },
              fg = 'NONE',
            },
          },
          {
            Visual = { bg = { from = 'Visual', alter = -0.65 }, fg = 'NONE' },
          },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
        },
        plugin = {
          { GitSignsAdd = { bg = 'NONE' } },
          { GitSignsChange = { bg = 'NONE' } },
          { GitSignsDelete = { bg = 'NONE' } },
          { WhichKeyBorder = { link = 'FloatBorder' } },
          { WhichKeyFloat = { link = 'Normal' } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/gnfisher/tomorrow-night-blue.nvim',
    lazy = false,
    cond = get_cond({ 'tomorrow-night-blue' }),
    init = function()
      theming.apply_overrides('tomorrow-night-blue', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.3 } } },
        },
      }, true)
    end,
    setup = function()
      require('tomorrow-night-blue').setup({
        transparent = ar.config.ui.transparent.enable,
      })
    end,
  },
  {
    src = 'https://github.com/razak17/zephyr-nvim',
    lazy = false,
    cond = get_cond({ 'zephyr' }),
    init = function()
      theming.apply_overrides('zephyr', {
        default = {
          { Normal = { bg = { from = 'Normal', alter = -0.5 } } },
          { Visual = { bg = { from = 'Visual', alter = -0.7 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.7 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ianklapouch/wildberries.nvim',
    lazy = false,
    cond = get_cond({ 'wildberries' }),
    init = function()
      local overrides = {
        default = {
          { LineNr = { fg = { from = 'LineNr', alter = -0.35 } } },
          { NonText = { fg = { from = 'NonText', alter = 0.4 } } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.4 } } },
          { StatusLine = { bg = 'NONE', reverse = false } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.2 } } },
          { Winbar = { link = 'Variable' } },
          { WinbarNC = { link = 'NonText' } },
          { MsgSeparator = { link = 'WinSeparator' } },
          { VertSplit = { link = 'WinSeparator' } },
          { IndentBlanklineChar = { link = 'VertSplit' } },
          { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
        },
        picker = {},
        plugin = {
          {
            GitSignsAdd = {
              fg = { from = 'DiffAdd', attr = 'bg', alter = 0.4 },
            },
          },
          {
            GitSignsChange = {
              fg = { from = 'DiagnosticInfo', attr = 'fg', alter = 0.2 },
            },
          },
        },
      }
      ar.list_insert(
        overrides,
        theming.generate_popup_overrides(),
        theming.generate_completion_overrides(),
        theming.generate_lsp_overrides(),
        theming.generate_picker_overrides(),
        {
          { SnacksPickerInput = { link = 'PickerPrompt' } },
          { SnacksPickerInputBorder = { link = 'PickerPromptBorder' } },
          { SnacksPickerInputTitle = { link = 'PickerTitle' } },
        }
      )
      theming.apply_overrides('wildberries', overrides)
    end,
  },
  {
    src = 'https://github.com/eldritch-theme/eldritch.nvim',
    lazy = false,
    cond = get_cond({ 'eldritch' }),
    init = function()
      theming.apply_overrides('eldritch', {
        default = {
          { Visual = { bg = { from = 'Visual', alter = -0.45 } } },
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.55 } },
          },
        },
      }, true)
    end,
    setup = function() require('eldritch').setup() end,
  },
  {
    src = 'https://github.com/judaew/ronny.nvim',
    lazy = false,
    cond = function() return colorscheme == 'ronny' end,
    init = function()
      theming.apply_overrides('ronny', {
        default = {
          { MatchParen = { link = 'Visual' } },
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.25 } },
          },
        },
      }, true)
    end,
    setup = function() require('ronny').setup() end,
  },
  {
    src = 'https://github.com/LunarVim/horizon.nvim',
    lazy = false,
    cond = get_cond({ 'horizon' }),
    init = function()
      theming.apply_overrides('horizon', {
        default = {
          { MatchParen = { link = 'Visual' } },
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.5 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/folke/tokyonight.nvim',
    lazy = false,
    cond = get_cond({ 'tokyonight' }),
    init = function()
      local overrides = {
        { NonText = { link = 'Comment' } },
        { StatusLine = { bg = 'NONE', reverse = false } },
        { Winbar = { link = 'Variable' } },
        { WinbarNC = { link = 'NonText' } },
        { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.25 } } },
        { MsgSeparator = { link = 'WinSeparator' } },
        { VertSplit = { link = 'WinSeparator' } },
        { Visual = { bg = { from = 'Visual', alter = 0.25 } } },
        { IndentBlanklineChar = { link = 'VertSplit' } },
        { IndentBlanklineContextChar = { link = 'IndentBlanklineChar' } },
      }
      ar.list_insert(
        overrides,
        theming.generate_popup_overrides(),
        theming.generate_completion_overrides(),
        theming.generate_lsp_overrides(),
        theming.generate_picker_overrides({
          { SnacksPicker = { link = 'PickerPrompt' } },
          { SnacksPickerBorder = { link = 'PickerPromptBorder' } },
          { SnacksPickerInput = { link = 'PickerPrompt' } },
          { SnacksPickerBoxBorder = { link = 'PickerPromptBorder' } },
          { SnacksPickerInputBorder = { link = 'PickerPromptBorder' } },
          { SnacksPickerInputTitle = { link = 'PickerTitle' } },
        })
      )
      theming.apply_overrides('tokyonight', { default = overrides })
    end,
    setup = function() require('tokyonight').setup() end,
  },
  {
    src = 'https://github.com/edeneast/nightfox.nvim',
    lazy = false,
    cond = get_cond({ 'nightfox' }),
    init = function()
      theming.apply_overrides('nightfox', {
        default = {
          { WinSeparator = { fg = { from = 'LineNr', alter = -0.45 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/rebelot/kanagawa.nvim',
    lazy = false,
    cond = get_cond({ 'kanagawa' }),
    init = function()
      theming.apply_overrides('kanagawa', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 1.45 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/ribru17/bamboo.nvim',
    lazy = false,
    cond = get_cond({ 'bamboo' }),
    init = function()
      theming.apply_overrides('bamboo', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.05 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Mofiqul/dracula.nvim',
    lazy = false,
    cond = get_cond({ 'dracula' }),
    init = function()
      theming.apply_overrides('dracula', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = 2.4 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/kylesnowschwartz/cobalt-neon.nvim',
    lazy = false,
    cond = get_cond({ 'cobalt-neon' }),
    init = function()
      theming.apply_overrides('cobalt-neon', {
        plugin = {
          { GitSignsAdd = { fg = { from = 'GitSignsAdd', alter = -0.25 } } },
          {
            GitSignsChange = { fg = { from = '@comment.note', attr = 'bg' } },
          },
        },
      }, true)
    end,
    setup = function() require('cobalt-neon').setup() end,
  },
  {
    src = 'https://github.com/nikita-edel/sugarpunk.nvim',
    lazy = false,
    cond = get_cond({ 'sugarpunk' }),
    init = function()
      theming.apply_overrides('sugarpunk', {
        default = {
          {
            WinSeparator = { fg = { from = 'WinSeparator', alter = -0.3 } },
          },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/morhetz/gruvbox',
    lazy = false,
    cond = get_cond({ 'gruvbox' }),
    init = function()
      theming.apply_overrides('gruvbox', {
        default = {
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
          { WinSeparator = { fg = { from = 'Dim', alter = -0.6 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/sainnhe/gruvbox-material',
    lazy = false,
    cond = get_cond({ 'gruvbox-material' }),
    init = function()
      theming.apply_overrides('gruvbox-material', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/Mofiqul/vscode.nvim',
    lazy = false,
    cond = get_cond({ 'vscode' }),
    init = function()
      theming.apply_overrides('vscode', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
  },
  {
    src = 'https://github.com/rockyzhang24/arctic.nvim',
    lazy = false,
    cond = get_cond({ 'arctic' }),
    init = function()
      theming.apply_overrides('arctic', {
        default = {
          { WinSeparator = { fg = { from = 'WinSeparator', alter = -0.1 } } },
        },
      }, true)
    end,
    dependencies = {
      { src = 'https://github.com/rktjmp/lush.nvim' },
    },
  },
})
