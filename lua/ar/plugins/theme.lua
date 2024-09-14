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
  {
    'eldritch-theme/eldritch.nvim',
    cond = ar.colorscheme == 'eldritch',
    priority = get_priority('eldritch'),
    event = get_event('eldritch'),
    opts = {},
  },
  {
    'ferdinandrau/lavish.nvim',
    cond = ar.colorscheme == 'lavish',
    priority = get_priority('lavish'),
    event = get_event('lavish'),
    config = function() require('lavish').apply() end,
  },
  {
    'Wansmer/serenity.nvim',
    cond = ar.colorscheme == 'serenity',
    priority = get_priority('serenity'),
    event = get_event('serenity'),
    opts = {},
  },
  {
    'oxfist/night-owl.nvim',
    priority = get_priority('night-owl'),
    event = get_event('night-owl'),
    cond = ar.colorscheme == 'night-owl',
  },
  {
    'judaew/ronny.nvim',
    cond = ar.colorscheme == 'ronny',
    priority = get_priority('ronny'),
    -- event = get_event('ronny'),
    opts = {},
  },
  {
    'kvrohit/rasmus.nvim',
    cond = ar.colorscheme == 'rasmus',
    priority = get_priority('rasmus'),
    event = get_event('rasmus'),
  },
  {
    'samharju/serene.nvim',
    cond = ar.colorscheme == 'serene',
    priority = get_priority('serene'),
    event = get_event('serene'),
  },
  {
    'slugbyte/lackluster.nvim',
    cond = ar.colorscheme == 'lackluster',
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
    'projekt0n/github-nvim-theme',
    cond = ar.colorscheme == 'github_dark',
    priority = get_priority('github_dark'),
    event = get_event('github_dark'),
  },
  {
    'LunarVim/horizon.nvim',
    cond = ar.colorscheme == 'horizon',
    priority = get_priority('horizon'),
    event = get_event('horizon'),
  },
  {
    'dotsilas/darcubox-nvim',
    cond = ar.colorscheme == 'darcubox',
    priority = get_priority('darcubox'),
    event = get_event('darcubox'),
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
    'dgox16/oldworld.nvim',
    cond = ar.colorscheme == 'oldworld',
    priority = get_priority('oldworld'),
    event = get_event('oldworld'),
    opts = {},
  },
  {
    'sontungexpt/witch',
    enabled = false,
    cond = ar.colorscheme == 'witch',
    priority = get_priority('witch'),
    event = get_event('witch'),
    opts = { style = 'dark' },
    config = function(_, opts) require('witch').setup(opts) end,
    -- Using lazy.nvim
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
    'atmosuwiryo/vim-winteriscoming',
    cond = ar.colorscheme == 'WinterIsComing-dark-color-theme',
    priority = get_priority('WinterIsComing-dark-color-theme'),
    event = get_event('WinterIsComing-dark-color-theme'),
  },
  {
    'https://git.sr.ht/~p00f/alabaster.nvim',
    cond = ar.colorscheme == 'alabaster',
    lazy = false,
    priority = 1000,
  },
  {
    'tribela/transparent.nvim',
    cond = ar.ui.transparent.enable,
    event = 'VimEnter',
    opts = {
      extra_groups = {
        'PopupNormal',
        'PopupBorder',
        'NormalFloat',
        'FloatBorder',
        'NeoTreeTabInactive',
        'NoiceMini',
        'NoicePopupBaseGroup',
        'NoicePopupWarnBaseGroup',
        'NoicePopupInfoBaseGroup',
        'NoiceCmdlinePopup',
        'NoiceCmdlinePopupBorder',
        'NoiceFormatProgressDone',
        'NoiceFormatProgressTodo',
        'NoiceLspProgressClient',
        'NoiceLspProgressSpinner',
        'NoiceLspProgressTitle',
        'NoiceFormatEvent',
        'NoiceConfirm',
        'NoiceConfirmBorder',
        'MarkviewCode',
        'MarkviewInlineCode',
        'PickerBorder',
        'PickerPromptNormal',
        'PickerPromptBorder',
        'PickerResultsNormal',
        'PickerResultsBorder',
        'PickerPreviewNormal',
        'PickerPreviewBorder',
        'PickerSelection',
      },
    },
    config = function(_, opts)
      require('transparent').setup(opts)

      ar.highlight.plugin('transparent', {
        theme = {
          ['onedark'] = {
            { MarkviewCode = { link = 'NormalFloat' } },
            { MarkviewInlineCode = { link = 'NormalFloat' } },
            { FloatBorder = { link = 'WinSeparator' } },
            { PickerBorder = { link = 'WinSeparator' } },
            { PickerPromptBorder = { link = 'WinSeparator' } },
            { PickerResultsBorder = { link = 'WinSeparator' } },
            { PickerPreviewBorder = { link = 'WinSeparator' } },
            { PopupBorder = { link = 'FloatBorder' } },
            {
              NoicePopupBaseGroup = {
                fg = { from = 'Directory', alter = -0.25 },
              },
            },
            { NoicePopupWarnBaseGroup = { link = 'NoicePopupBaseGroup' } },
            { NoicePopupInfoBaseGroup = { link = 'NoicePopupBaseGroup' } },
          },
        },
      })
    end,
  },
  -- }}}
}
