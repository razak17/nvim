local ok, which_key = rvim.safe_require('which-key')
if ok then which_key.register({ ['<localleader>'] = { r = { name = 'Rust Tools' } } }) end

require('typescript').setup({ server = require('user.servers').setup('tsserver') })
require('null-ls').register({
  sources = { require('typescript.extensions.null-ls.code-actions') },
})
