local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    '4513ECHO/nvim-keycastr',
    cond = not minimal and niceties and false,
    init = function()
      local enabled = false
      local config_set = false
      ar.command('KeyCastrToggle', function()
        local keycastr = require('keycastr')
        if not config_set then
          keycastr.config.set({
            win_config = { border = 'single' },
            position = 'SE',
          })
          config_set = true
        end
        keycastr[enabled and 'disable' or 'enable']()
        enabled = not enabled
        vim.notify(('Keycastr %s'):format(enabled and 'disabled' or 'enabled'))
      end, {})
      vim.keymap.set(
        'n',
        '<leader>ok',
        '<Cmd>KeyCastrToggle<CR>',
        { desc = 'keycastr: toggle' }
      )
    end,
  },
  {
    'nvchad/showkeys',
    cond = not minimal,
    init = function()
      ar.add_to_menu(
        'command_palette',
        { ['Toggle Screencaster'] = 'ShowkeysToggle' }
      )
    end,
    cmd = 'ShowkeysToggle',
    opts = {
      position = 'top-right',
      timeout = 1,
      maxkeys = 17,
    },
  },
}
