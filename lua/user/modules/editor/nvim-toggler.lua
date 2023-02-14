local M = {
  'nguyenvukhang/nvim-toggler',
  event = 'VeryLazy',
  init = function()
    rvim.nnoremap(
      '<leader>ii',
      '<cmd>lua require("nvim-toggler").toggle()<CR>',
      'nvim-toggler: toggle'
    )
  end,
}

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
      ['chore'] = 'feat',
      ['double'] = 'single',
    },
    remove_default_keybinds = true,
  })
end

return M
