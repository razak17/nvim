local minimal = ar.plugins.minimal

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
  { 'dundalek/bloat.nvim', cmd = 'Bloat' },
  { 'tyru/capture.vim', cmd = { 'Capture' } },
  { 'will133/vim-dirdiff', cmd = { 'DirDiff' } },
  { 'godlygeek/tabular', cmd = { 'Tabularize' } },
  { 'Rasukarusan/nvim-block-paste', cmd = { 'Block' } },
  { 'meznaric/key-analyzer.nvim', cmd = { 'KeyAnalyzer' }, opts = {} },
  {
    'razak17/lspkind.nvim',
    config = function() require('lspkind').init({ preset = 'codicons' }) end,
  },
  {
    'neuromaancer/readup.nvim',
    cmd = { 'Readup', 'ReadupBrowser' },
    opts = { float = true },
  },
  {
    'AndrewRadev/linediff.vim',
    cond = function() return ar.get_plugin_cond('linediff.vim', not minimal) end,
    cmd = 'Linediff',
    keys = {
      { '<localleader>lL', '<cmd>Linediff<CR>', desc = 'linediff: toggle' },
    },
  },
}
