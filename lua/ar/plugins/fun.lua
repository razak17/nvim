local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'Rasukarusan/nvim-block-paste',
    cond = function() return ar.get_plugin_cond('nvim-block-paste') end,
    cmd = { 'Block' },
  },
  {
    'koron/nyancat-vim',
    cond = function() return ar.get_plugin_cond('nyancat-vim') end,
    cmd = { 'Nyancat', 'Nyancat2' },
  },
  {
    'r-cha/encourage.nvim',
    cond = function()
      local condition = not minimal and niceties
      return ar.get_plugin_cond('encourage.nvim', condition)
    end,
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {},
  },
  {
    'tjdevries/sPoNGe-BoB.NvIm',
    cond = function() return ar.get_plugin_cond('sPoNGe-BoB.NvIm') end,
    cmd = { 'SpOnGeBoBiFy' },
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle SpOnGeBoB'] = 'SpOnGeBoBiFy' })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>ab', '<cmd>SpOnGeBoBiFy<CR>', mode = { 'v' }, desc = 'SpOnGeBoB: SpOnGeBoBiFy', },
    },
  },
  {
    'GitMarkedDan/you-are-an-idiot.nvim',
    cond = function()
      return ar.get_plugin_cond('you-are-an-idiot.nvim', not minimal)
    end,
    cmd = { 'ToggleIdiot' },
    init = function()
      ar.add_to_select_menu('toggle', { ['Toggle Idiot'] = 'ToggleIdiot' })
    end,
    config = function()
      local idiot = require('you-are-an-idiot')
      vim.api.nvim_create_user_command('ToggleIdiot', function()
        if idiot.is_running() then
          idiot.abort()
        else
          idiot.run()
        end
      end, { desc = 'Toggles YouAreAnIdiot' })
    end,
  },
  {
    desc = 'Vim plugin: footprints. Highlight last edited lines.',
    'axlebedev/vim-footprints',
    cond = function() return ar.get_plugin_cond('vim-footprints', not minimal) end,
    lazy = false,
    cmd = {
      'FootprintsToggle',
      'FootprintsEnable',
      'FootprintsDisable',
      'FootprintsBufferToggle',
      'FootprintsBufferEnable',
      'FootprintsBufferDisable',
      'FootprintsCurrentLineToggle',
      'FootprintsCurrentLineEnable',
      'FootprintsCurrentLineDisable',
    },
    init = function()
      vim.g.footprintsColor = ar.highlight.get('CursorLine', 'bg')
      vim.g.footprintsTermColor = '208'
      vim.g.footprintsEasingFunction = 'linear'
      vim.g.footprintsHistoryDepth = 20
      vim.g.footprintsExcludeFiletypes = { 'magit', 'nerdtree', 'diff' }
      vim.g.footprintsEnabledByDefault = 0
      vim.g.footprintsOnCurrentLine = 0

      ar.add_to_select_menu('toggle', {
        ['Toggle Footprints'] = 'FootprintsToggle',
        ['Enable Footprints'] = 'FootprintsEnable',
        ['Disable Footprints'] = 'FootprintsDisable',
        ['Toggle Footprints Buffer'] = 'FootprintsBufferToggle',
        ['Enable Footprints Buffer'] = 'FootprintsBufferEnable',
        ['Disable Footprints Buffer'] = 'FootprintsBufferDisable',
        ['Toggle Footprints Current Line'] = 'FootprintsCurrentLineToggle',
        ['Enable Footprints Current Line'] = 'FootprintsCurrentLineEnable',
        ['Disable Footprints Current Line'] = 'FootprintsCurrentLineDisable',
      })
    end,
  },
}
