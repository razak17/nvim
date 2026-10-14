if not ar.get_plugin_cond('crates.nvim', not ar.plugins.minimal) then
  return false
end

vim.api.nvim_create_autocmd('BufReadPre', {
  pattern = 'Cargo.toml',
  once = true,
  callback = function()
    ar.pack.add({
      src = 'https://github.com/Saecki/crates.nvim',
      lazy = false,
      setup = function()
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
      end,
    })
  end,
})
return true
