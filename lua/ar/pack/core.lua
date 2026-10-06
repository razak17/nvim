vim.pack.add(
  { 'https://github.com/nvim-lua/plenary.nvim' },
  { confirm = false }
)

vim.pack.add(
  { 'https://github.com/rosstang/lunajson.nvim' },
  { confirm = false }
)

vim.pack.add({
  'https://github.com/b0o/schemastore.nvim',
}, { confirm = false })

vim.pack.add({ 'https://github.com/razak17/lspkind.nvim' }, { confirm = false })
require('lspkind').init({ preset = 'codicons' })
