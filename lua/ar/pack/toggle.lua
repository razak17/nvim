ar.pack.add({
  {
    src = 'https://github.com/nguyenvukhang/nvim-toggler',
    cond = function()
      return ar.get_plugin_cond('nvim-toggler', ar.plugins.coding)
    end,
    keys = {
      {
        '<leader>ii',
        function() require('nvim-toggler').toggle() end,
        desc = 'nvim-toggler: toggle',
      },
    },
    setup = function()
      require('nvim-toggler').setup({
        remove_default_keybinds = true,
        inverses = {
          ['=='] = '~=',
          ['==='] = '!==',
          ['vim'] = 'emacs',
          ['let'] = 'const',
          ['margin'] = 'padding',
          ['-'] = '+',
          ['onClick'] = 'onSubmit',
          ['public'] = 'private',
          ['string'] = 'int',
          ['leader'] = 'localleader',
          ['chore'] = 'feat',
          ['double'] = 'single',
          ['config'] = 'opts',
          ['pre'] = 'post',
          ['column'] = 'row',
          ['before'] = 'after',
          ['end'] = 'start',
          ['high'] = 'low',
          ['open'] = 'close',
          ['and'] = 'or',
          ['GET'] = 'POST',
        },
      })
    end,
  },
})
