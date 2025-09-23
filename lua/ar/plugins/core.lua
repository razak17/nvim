return {
  ------------------------------------------------------------------------------
  -- Core {{{1
  ------------------------------------------------------------------------------
  'nvim-lua/plenary.nvim',
  'MunifTanjim/nui.nvim',
  'b0o/schemastore.nvim',
  'kevinhwang91/promise-async',
  'kkharji/sqlite.lua',
  'tpope/vim-rhubarb',
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  { 'Rasukarusan/nvim-block-paste', cmd = { 'Block' } },
  { 'meznaric/key-analyzer.nvim', cmd = { 'KeyAnalyzer' }, opts = {} },
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  { 'rosstang/lunajson.nvim' },
}
