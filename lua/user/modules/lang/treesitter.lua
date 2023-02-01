local M = {
  'nvim-treesitter/nvim-treesitter',
  event = 'BufReadPost',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'mrjones2014/nvim-ts-rainbow',
    {
      'nvim-treesitter/nvim-treesitter-context',
      event = { 'BufRead', 'BufNewFile' },
      config = function()
        require('user.utils.highlights').plugin('treesitter-context', {
          { ContextBorder = { link = 'FloatBorder' } },
          { TreesitterContext = { inherit = 'Normal' } },
          { TreesitterContextLineNumber = { inherit = 'LineNr' } },
        })
        require('treesitter-context').setup({
          multiline_threshold = 4,
          separator = { '─', 'ContextBorder' }, --[[alernatives: ▁ ─ ▄ ]]
          mode = 'topline',
        })
      end,
    },
    {
      'windwp/nvim-ts-autotag',
      event = 'InsertEnter',
      config = function()
        require('nvim-ts-autotag').setup({
          filetypes = { 'html', 'xml', 'typescriptreact', 'javascriptreact' },
        })
      end,
    },
  },
}

function M.init()
  rvim.nnoremap('R', '<cmd>edit | TSBufEnable highlight<CR>', 'treesitter: enable highlight')
end

function M.config()
  -- This option, which currently doesn't work upstream, disables linking treesitter highlights
  -- to the new capture highlights which color schemes and plugins depend on. By toggling it
  -- I can see which highlights still need to be supported in upstream plugins.
  -- NOTE: this is currently broken, do not set to true
  vim.g.skip_ts_default_groups = false

  local status_ok, treesitter_configs = rvim.safe_require('nvim-treesitter.configs')
  if not status_ok then return end

  treesitter_configs.setup({
    auto_install = true,
    highlight = { enable = true },
    context_commentstring = {
      enable = true,
      enable_autocmd = false,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<CR>', -- maps in normal mode to init the node/scope selection
        node_incremental = '<CR>', -- increment to the upper named parent
        node_decremental = '<C-CR>', -- decrement to the previous node
      },
    },
    textobjects = {
      select = {
        enable = false,
      },
      move = {
        enable = false,
      },
      lsp_interop = {
        enable = false,
      },
    },
    indent = { enable = { 'javascriptreact' } },
    matchup = { enable = true, disable = { 'c', 'python' } },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
      disable = { 'lua', 'json', 'c', 'cpp', 'html' },
      colors = { 'royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3' },
    },
    query_linter = {
      enable = true,
      use_virtual_text = true,
      lint_events = { 'BufWrite', 'CursorHold' },
    },
    playground = { persist_queries = true },
    ensure_installed = {
      'lua',
      'dart',
      'rust',
      'typescript',
      'tsx',
      'javascript',
      -- "comment", -- comments are slowing down TS bigtime, so disable for now
      'markdown',
      'markdown_inline',
      'prisma',
      'graphql',
      'go',
      'python',
      'json',
      'http',
      'help',
      'git_rebase',
      'bash',
      'c',
      'diff',
      'toml',
      'cpp',
      'jsonc',
    },
  })
end

return M
