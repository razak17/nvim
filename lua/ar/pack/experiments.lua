ar.pack.add({
  {
    src = 'https://github.com/mikesmithgh/kitty-scrollback.nvim',
    cond = function() return ar.get_plugin_cond('kitty-scrollback.nvim') end,
    cmd = {
      'KittyScrollbackGenerateKittens',
      'KittyScrollbackCheckHealth',
      'KittyScrollbackGenerateCommandLineEditing',
    },
    keys = function(load)
      vim.api.nvim_create_autocmd('User', {
        pattern = 'KittyScrollbackLaunch',
        once = true,
        callback = load,
      })
    end,
    setup = function()
      require('kitty-scrollback').setup({
        {
          callbacks = {
            after_ready = function()
              vim.defer_fn(
                function()
                  vim.fn.confirm(
                    vim.env.NVIM_APPNAME .. ' kitty-scrollback.nvim example!'
                  )
                end,
                1000
              )
            end,
          },
        },
      })
    end,
  },
})
