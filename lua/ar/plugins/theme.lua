local function is_colorscheme(name) return ar.colorscheme == name end

local function get_priority(name) return is_colorscheme(name) and 1000 or 50 end

local function get_event(name)
  return is_colorscheme(name) and { 'UiEnter' } or { 'VeryLazy' }
end

return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  {
    'razak17/onedark.nvim',
    cond = ar.colorscheme == 'onedark',
    priority = get_priority('onedark'),
    event = get_event('onedark'),
    opts = { variant = 'fill' },
  },
  ------------------------------------------------------------------------------
  -- Monochrome
  {
    'slugbyte/lackluster.nvim',
    -- cond = ar.colorscheme == 'lackluster',
    priority = get_priority('lackluster'),
    event = get_event('lackluster'),
    opts = function()
      local lackluster = require('lackluster')
      local color = lackluster.color
      return {
        tweek_syntax = { comment = color.gray4 },
        tweek_background = {
          normal = 'none',
          telescope = 'none',
          menu = color.gray3,
          popup = 'default',
        },
      }
    end,
    config = function(_, opts)
      require('lackluster').setup(opts)

      if is_colorscheme('lackluster') then
        vim.cmd.colorscheme('lackluster')
        vim.g.colors_name = 'lackluster'
      end
    end,
  },
  {
    'wnkz/monoglow.nvim',
    -- cond = ar.colorscheme == 'monoglow',
    priority = get_priority('monoglow'),
    event = get_event('monoglow'),
    opts = {},
  },
  {
    'aktersnurra/no-clown-fiesta.nvim',
    -- cond = ar.colorscheme == 'no-clown-fiesta',
    priority = get_priority('no-clown-fiesta'),
    event = get_event('no-clown-fiesta'),
    opts = {},
  },
  {
    'dgox16/oldworld.nvim',
    -- cond = ar.colorscheme == 'oldworld',
    priority = get_priority('oldworld'),
    event = get_event('oldworld'),
    opts = {},
  },
  {
    'kvrohit/rasmus.nvim',
    -- cond = ar.colorscheme == 'rasmus',
    priority = get_priority('rasmus'),
    event = get_event('rasmus'),
  },
  {
    'samharju/serene.nvim',
    -- cond = ar.colorscheme == 'serene',
    priority = get_priority('serene'),
    event = get_event('serene'),
  },
  {
    'Wansmer/serenity.nvim',
    -- cond = ar.colorscheme == 'serenity',
    priority = get_priority('serenity'),
    event = get_event('serenity'),
    opts = {},
  },
  {
    'ficcdaf/ashen.nvim',
    -- cond = ar.colorscheme == 'ashen',
    priority = get_priority('ashen'),
    event = get_event('ashen'),
  },
  {
    'dotsilas/darcubox-nvim',
    -- cond = ar.colorscheme == 'darcubox',
    priority = get_priority('darcubox'),
    event = get_event('darcubox'),
  },
  {
    'https://git.sr.ht/~p00f/alabaster.nvim',
    -- cond = ar.colorscheme == 'alabaster',
    priority = get_priority('alabaster'),
    event = get_event('alabaster'),
  },
  {
    'masar3141/mono-jade',
    -- cond = ar.colorscheme == 'mono-jade',
    priority = get_priority('mono-jade'),
    event = get_event('mono-jade'),
  },
  {
    'ferdinandrau/lavish.nvim',
    -- cond = ar.colorscheme == 'lavish',
    priority = get_priority('lavish'),
    event = get_event('lavish'),
    -- config = function() require('lavish').apply() end,
  },
  {
    'olivercederborg/poimandres.nvim',
    cond = ar.colorscheme == 'poimandres', -- NOTE: clears highlighting on init
    priority = get_priority('poimandres'),
    event = get_event('poimandres'),
    opts = {},
  },
  ------------------------------------------------------------------------------
  -- Mild
  {
    'savq/melange-nvim',
    cond = ar.colorscheme == 'melange',
    priority = get_priority('melange'),
    event = get_event('melange'),
  },
  {
    'oxfist/night-owl.nvim',
    priority = get_priority('night-owl'),
    event = get_event('night-owl'),
    cond = ar.colorscheme == 'night-owl',
  },
  {
    'atmosuwiryo/vim-winteriscoming',
    cond = ar.colorscheme == 'WinterIsComing-dark-color-theme',
    priority = get_priority('WinterIsComing-dark-color-theme'),
    event = get_event('WinterIsComing-dark-color-theme'),
  },
  {
    'projekt0n/github-nvim-theme',
    cond = ar.colorscheme == 'github_dark',
    priority = get_priority('github_dark'),
    event = get_event('github_dark'),
  },
  {
    'NTBBloodbath/doom-one.nvim',
    cond = ar.colorscheme == 'doom-one',
    priority = get_priority('doom-one'),
    event = get_event('doom-one'),
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  {
    'neanias/everforest-nvim',
    cond = ar.colorscheme == 'everforest',
    priority = get_priority('everforest'),
    event = get_event('everforest'),
    opts = {},
    config = function(_, opts) require('everforest').setup(opts) end,
  },
  {
    'nuvic/flexoki-nvim',
    name = 'flexoki',
    cond = ar.colorscheme == 'flexoki',
    priority = get_priority('flexoki'),
    event = get_event('flexoki'),
    opts = {},
  },
  {
    'aliqyan-21/darkvoid.nvim',
    cond = ar.colorscheme == 'darkvoid',
    priority = get_priority('darkvoid'),
    event = get_event('darkvoid'),
  },
  {
    'lunarvim/lunar.nvim',
    cond = ar.colorscheme == 'lunar',
    priority = get_priority('lunar'),
    event = get_event('lunar'),
  },
  {
    'philosofonusus/morta.nvim',
    name = 'morta',
    cond = ar.colorscheme == 'morta',
    priority = get_priority('morta'),
    event = get_event('morta'),
  },
  ------------------------------------------------------------------------------
  -- Clown show
  {
    'eldritch-theme/eldritch.nvim',
    cond = ar.colorscheme == 'eldritch',
    priority = get_priority('eldritch'),
    event = get_event('eldritch'),
    opts = {},
  },
  {
    'judaew/ronny.nvim',
    cond = ar.colorscheme == 'ronny',
    priority = get_priority('ronny'),
    -- event = get_event('ronny'),
    opts = {},
  },
  {
    'LunarVim/horizon.nvim',
    cond = ar.colorscheme == 'horizon',
    priority = get_priority('horizon'),
    event = get_event('horizon'),
  },
  {
    'scottmckendry/cyberdream.nvim',
    cond = ar.colorscheme == 'cyberdream',
    priority = get_priority('cyberdream'),
    event = get_event('cyberdream'),
    opts = {},
  },
  {
    'folke/tokyonight.nvim',
    cond = ar.colorscheme == 'tokyonight',
    priority = get_priority('tokyonight'),
    event = get_event('tokyonight'),
    opts = {},
  },
  {
    'wtfox/jellybeans.nvim',
    -- cond = ar.colorscheme == 'jellybeans',
    priority = get_priority('jellybeans'),
    event = get_event('jellybeans'),
  },
  -- }}}
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'sontungexpt/witch',
    enabled = false,
    cond = ar.colorscheme == 'witch',
    priority = get_priority('witch'),
    event = get_event('witch'),
    opts = { style = 'dark' },
    config = function(_, opts) require('witch').setup(opts) end,
  },
  {
    'cdmill/neomodern.nvim',
    enabled = false,
    cond = ar.colorscheme == 'neomodern',
    priority = get_priority('neomodern'),
    event = get_event('neomodern'),
    config = function()
      require('neomodern').setup({
        highlights = {
          ['@namespace'] = { fg = '$constant' },
          ['@include'] = { fg = '$keyword' },
          ['@method'] = { fg = '$func' },
          ['@storageclass'] = { fg = '$constant' },
          ['@preProc'] = { fg = '$preproc' },
          ['@field'] = { fg = '$property' },
        },
      })
      require('neomodern').load()
    end,
  },
}
