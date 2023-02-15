local ok, which_key = rvim.safe_require('which-key')
if ok then which_key.register({ ['<localleader>'] = { r = { name = 'Rust Tools' } } }) end

require('typescript').setup({
  server = {
    -- NOTE: Apparently setting this to false improves performance
    -- https://github.com/sublimelsp/LSP-typescript/issues/129#issuecomment-1281643371
    initializationOptions = {
      preferences = {
        includeCompletionsForModuleExports = false,
      },
    },
  },
})
