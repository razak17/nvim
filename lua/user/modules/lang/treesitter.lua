local M = {
  'nvim-treesitter/nvim-treesitter',
  event = 'BufReadPost',
  build = ':TSUpdate',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'p00f/nvim-ts-rainbow',
    {
      'nvim-treesitter/nvim-treesitter-context',
      event = { 'BufRead', 'BufNewFile' },
      config = function()
        require('user.utils.highlights').plugin('treesitter-context', {
          { ContextBorder = { link = 'Dim' } },
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

  ---Get all filetypes for which we have a treesitter parser installed
  ---@return string[]
  local function get_filetypes()
    local parsers = require('nvim-treesitter.parsers')
    local configs = parsers.get_parser_configs()
    return vim.tbl_map(
      function(ft) return configs[ft].filetype or ft end,
      parsers.available_parsers()
    )
  end

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
      lookahead = true,
      select = {
        enable = true,
        include_surrounding_whitespace = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['aC'] = '@conditional.outer',
          ['iC'] = '@conditional.inner',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['[w'] = '@parameter.inner',
        },
        swap_previous = {
          [']w'] = '@parameter.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']m'] = '@function.outer',
          [']c'] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[c'] = '@class.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = rvim.style.border.current,
        peek_definition_code = {
          ['<leader>lu'] = '@function.outer',
          ['<leader>lC'] = '@class.outer',
        },
      },
    },
    indent = { enable = { 'javascriptreact' } },
    matchup = { enable = true, disable = { 'c', 'python' } },
    autopairs = { enable = true },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 1000,
      disable = { 'lua', 'json', 'c', 'cpp', 'html' },
      colors = {
        'royalblue3',
        'darkorange3',
        'seagreen3',
        'firebrick',
        'darkorchid3',
      },
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
      'javascript',
      'comment',
      'markdown',
      'markdown_inline',
      'prisma',
      'graphql',
      'go',
      'git_rebase',
    },
  })

  -- Only apply folding to supported files:
  rvim.augroup('TreesitterFolds', {
    {
      event = { 'FileType' },
      pattern = get_filetypes(),
      command = function()
        vim.cmd('setlocal foldexpr=nvim_treesitter#foldexpr()')
        vim.cmd('setlocal foldmethod=expr')
      end,
    },
  })
end

return M
