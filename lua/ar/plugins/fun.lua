local minimal = ar.plugins.minimal

return {
  {
    'koron/nyancat-vim',
    cond = function() ar.get_plugin_cond('nyancat-vim') end,
    cmd = { 'Nyancat', 'Nyancat2' },
  },
  {
    'tjdevries/sPoNGe-BoB.NvIm',
    cond = function() ar.get_plugin_cond('sPoNGe-BoB.NvIm') end,
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
}
