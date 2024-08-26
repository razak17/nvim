local minimal = ar.plugins.minimal

return {
  ------------------------------------------------------------------------------
  -- Themes {{{1
  ------------------------------------------------------------------------------
  { 'Wansmer/serenity.nvim', priority = 1000, cond = not minimal, opts = {} },
  { 'judaew/ronny.nvim', priority = 1000, cond = not minimal, opts = {} },
  -- { 'oxfist/night-owl.nvim', lazy = false, priority = 1000 },
  { 'kvrohit/rasmus.nvim', lazy = false, cond = not minimal, priority = 1000 },
  { 'samharju/serene.nvim', lazy = false, cond = not minimal, priority = 1000 },
  {
    'razak17/onedark.nvim',
    lazy = false,
    priority = 1000,
    opts = { variant = 'fill' },
  },
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
    cond = not minimal,
    priority = 1000,
  },
  {
    'LunarVim/horizon.nvim',
    lazy = false,
    cond = not minimal,
    priority = 1000,
  },
  {
    'dotsilas/darcubox-nvim',
    lazy = false,
    cond = not minimal,
    priority = 1000,
  },
  {
    'NTBBloodbath/doom-one.nvim',
    cond = not minimal,
    lazy = false,
    config = function()
      vim.g.doom_one_pumblend_enable = true
      vim.g.doom_one_pumblend_transparency = 3
    end,
  },
  {
    'dgox16/oldworld.nvim',
    cond = not minimal,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'sontungexpt/witch',
    enabled = false,
    cond = not minimal and false,
    priority = 1000,
    lazy = false,
    opts = { style = 'dark' },
    config = function(_, opts) require('witch').setup(opts) end,
    -- Using lazy.nvim
    {
      'cdmill/neomodern.nvim',
      enabled = false,
      cond = not minimal and false,
      lazy = false,
      priority = 1000,
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
    cond = not minimal,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'folke/tokyonight.nvim',
    cond = not minimal,
    lazy = false,
    priority = 1000,
    opts = {},
  },
  {
    'atmosuwiryo/vim-winteriscoming',
    cond = not minimal,
    lazy = false,
    priority = 1000,
  },
  {
    'https://git.sr.ht/~p00f/alabaster.nvim',
    cond = not minimal,
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
