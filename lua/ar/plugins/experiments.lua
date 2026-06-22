local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'mikesmithgh/kitty-scrollback.nvim',
    cond = function() return ar.get_plugin_cond('kitty-scrollback.nvim') end,
    cmd = {
      'KittyScrollbackGenerateKittens',
      'KittyScrollbackCheckHealth',
      'KittyScrollbackGenerateCommandLineEditing',
    },
    event = { 'User KittyScrollbackLaunch' },
    config = function()
      require('kitty-scrollback').setup({
        {
          callbacks = {
            after_ready = vim.defer_fn(
              function()
                vim.fn.confirm(
                  vim.env.NVIM_APPNAME .. ' kitty-scrollback.nvim example!'
                )
              end,
              1000
            ),
          },
        },
      })
    end,
  },
}
