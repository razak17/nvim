if not ar.get_plugin_cond('lazydev.nvim', ar.lsp.enable) then return false end

local loaded = false

local function load()
  if loaded then return end
  vim.pack.add({ 'https://github.com/folke/lazydev.nvim' }, { confirm = false })
  require('lazydev').setup({
    library = {
      'lazy.nvim',
      { path = 'nvim-lspconfig', words = { 'lspconfig' } },
    },
  })
  loaded = true
end

ar.pack.cmd('LazyDev', load)

vim.api.nvim_create_autocmd('BufRead', {
  pattern = vim.fn.stdpath('config') .. '**/*.lua',
  once = true,
  callback = load,
})
return true
