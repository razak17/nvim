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
      ar.add_to_select('toggle', { ['Toggle SpOnGeBoB'] = 'SpOnGeBoBiFy' })
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
      ar.add_to_select('toggle', { ['Toggle Idiot'] = 'ToggleIdiot' })
    end,
    config = function()
      local idiot = require('you-are-an-idiot')
      vim.api.nvim_create_user_command('ToggleIdiot', function()
        if idiot.is_running() then
          idiot.abort()
        else
          idiot.run()
        end
      end, { desc = 'Toggle YouAreAnIdiot' })
    end,
  },
  {
    desc = 'nVim plugin: footprints. Highlight last edited lines.',
    'axlebedev/nvim-footprints',
    cond = function() return ar.get_plugin_cond('nvim-footprints', not minimal) end,
    event = 'VeryLazy',
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
      ar.add_to_select('toggle', {
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
    opts = {
      footprintsColor = ar.highlight.get('CursorLine', 'bg'),
      footprintsTermColor = '208',
      footprintsEasingFunction = 'linear',
      footprintsHistoryDepth = 20,
      footprintsExcludeFiletypes = { 'magit', 'nerdtree', 'diff' },
      footprintsEnabledByDefault = 0,
      footprintsOnCurrentLine = 0,
    },
  },
}
