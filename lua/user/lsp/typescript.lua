require('which-key').register({
  ['<localleader>t'] = { name = 'Typescript' },
  ['<localleader>ti'] = { name = 'Imports' },
})

require('typescript').setup({ server = require('user.servers')('tsserver') })
require('null-ls').register({
  sources = { require('typescript.extensions.null-ls.code-actions') },
})
