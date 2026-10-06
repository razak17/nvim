if not ar.get_plugin_cond('crates.nvim', not ar.plugins.minimal) then
  return false
end

local loaded = false
local function load()
  if loaded then return end
  vim.pack.add({
    'https://github.com/Saecki/crates.nvim',
  }, { confirm = false })
  vim.g.whichkey_add_spec({ '<leader><localleader>c', group = 'Crates' })
  require('crates').setup({
    popup = {
      autofocus = true,
      border = ar.ui.current.border.default,
    },
    -- TODO: lsp integration seems to have issues
    lsp = {
      enabled = ar.lsp.enable,
      actions = true,
      completion = true,
      hover = true,
    },
  })
  loaded = true
end

vim.api.nvim_create_autocmd('BufRead', {
  pattern = 'Cargo.toml',
  once = true,
  callback = load,
})
return true
