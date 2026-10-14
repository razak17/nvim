ar.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim', lazy = false },
  { src = 'https://github.com/rosstang/lunajson.nvim', lazy = false },
  { src = 'https://github.com/b0o/schemastore.nvim', lazy = false },
  {
    src = 'https://github.com/razak17/lspkind.nvim',
    lazy = false,
    setup = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  {
    src = 'https://github.com/mariocesar/beside.nvim',
    cmd = { 'Beside' },
    setup = function() require('beside').setup() end,
  },
})
