local function is_colorscheme(name) return ar_config.colorscheme == name end

--- Get colorscheme cond
---@param names table
---@return boolean
local function get_cond(names)
  if ar.plugins.niceties then return true end
  return not ar.plugins.minimal
    and vim.tbl_contains(names, ar_config.colorscheme)
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
    cond = ar_config.colorscheme == 'onedark',
    priority = get_priority({ 'onedark' }),
    event = get_event({ 'onedark' }),
    opts = { variant = 'fill' },
  },
  ------------------------------------------------------------------------------
  -- Monochrome
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
      if ar_config.colorscheme == 'neomodern' then
        require('neomodern').load()
      end
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
    cond = get_cond({ 'monoglow' }),
    priority = get_priority({ 'monoglow' }),
    event = get_event({ 'monoglow' }),
    opts = {},
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
    'https://git.sr.ht/~p00f/alabaster.nvim',
    cond = get_cond({ 'alabaster' }),
    priority = get_priority({ 'alabaster' }),
    event = get_event({ 'alabaster' }),
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
  ------------------------------------------------------------------------------
  -- Warm
  {
    'savq/melange-nvim',
    cond = get_cond({ 'melange' }),
    priority = get_priority({ 'melange' }),
    event = get_event({ 'melange' }),
  },
  ------------------------------------------------------------------------------
  -- Mild
  {
    -- NOTE: Double underlines markdown headings
    'oxfist/night-owl.nvim',
    priority = get_priority({ 'night-owl' }),
    -- event = get_event({ 'night-owl' }),
    -- cond = get_cond({ 'night-owl' }),
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
    opts = {},
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
  },
  {
    'philosofonusus/morta.nvim',
    name = 'morta',
    cond = get_cond({ 'morta' }),
    priority = get_priority({ 'morta' }),
    event = get_event({ 'morta' }),
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
    cond = get_cond({ 'ronny' }),
    priority = get_priority({ 'ronny' }),
    -- event = get_event({'ronny'}),
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
  -- }}}
}
