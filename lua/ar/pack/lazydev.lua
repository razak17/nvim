if not ar.get_plugin_cond('lazydev.nvim', ar.lsp.enable) then return false end

ar.pack.add({
  src = 'https://github.com/folke/lazydev.nvim',
  cmd = { 'LazyDev' },
  keys = function(load)
    vim.api.nvim_create_autocmd('BufRead', {
      pattern = vim.fn.stdpath('config') .. '**/*.lua',
      once = true,
      callback = load,
    })
  end,
  setup = function()
    require('lazydev').setup({
      library = {
        'lazy.nvim',
        { path = 'nvim-lspconfig', words = { 'lspconfig' } },
      },
    })
  end,
})
return true
