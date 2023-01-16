local M = { 'nguyenvukhang/nvim-toggler', event = 'VeryLazy' }

function M.init()
  rvim.nnoremap(
    '<leader>ii',
    '<cmd>lua require("nvim-toggler").toggle()<CR>',
    'nvim-toggler: toggle'
  )
end

function M.config()
  require('nvim-toggler').setup({
    inverses = {
      ['vim'] = 'emacs',
      ['let'] = 'const',
      ['margin'] = 'padding',
      ['-'] = '+',
      ['onClick'] = 'onSubmit',
      ['public'] = 'private',
      ['string'] = 'int',
      ['leader'] = 'localleader',
    },
    remove_default_keybinds = true,
  })
end

return M
