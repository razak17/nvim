return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        context_commentstring = { enable = true, enable_autocmd = false },
        incremental_selection = {
          enable = true,
          disable = { 'help' },
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
              ['af'] = { query = '@function.outer', desc = 'ts: all function' },
              ['if'] = { query = '@function.inner', desc = 'ts: inner function' },
              ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
              ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
              ['aC'] = { query = '@conditional.outer', desc = 'ts: all conditional' },
              ['iC'] = { query = '@conditional.inner', desc = 'ts: inner conditional' },
              ['aH'] = { query = '@assignment.lhs', desc = 'ts: assignment lhs' },
              ['aL'] = { query = '@assignment.rhs', desc = 'ts: assignment rhs' },
            },
          },
          move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = { [']m'] = '@function.outer', [']c'] = '@class.outer' },
            goto_previous_start = { ['[m'] = '@function.outer', ['[c'] = '@class.outer' },
          },
          lsp_interop = { enable = false },
        },
        indent = { enable = { 'javascriptreact' } },
        matchup = { enable = true, disable = { 'c', 'python' } },
        rainbow = {
          enable = true,
          disable = false,
          query = {
            'rainbow-parens',
            html = function() return nil end,
            tsx = function() return nil end,
            javascript = function() return nil end,
          },
          strategy = { require('ts-rainbow.strategy.local') },
        },
        query_linter = {
          enable = true,
          use_virtual_text = false,
          lint_events = { 'BufWrite', 'CursorHold' },
        },
        playground = { persist_queries = true },
        -- stylua: ignore
        ensure_installed = {
          'lua', 'dart', 'rust', 'typescript', 'tsx', 'javascript', 'markdown', 'markdown_inline',
          'prisma', 'graphql', 'go', 'python', 'json', 'http', 'help', 'git_rebase', 'bash', 'c',
          'diff', 'toml', 'cpp', 'jsonc', 'query',
        },
      })

      map('n', 'R', '<cmd>edit | TSBufEnable highlight<CR>', { desc = 'treesitter: enable highlight' })
    end,
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects', 'HiPhish/nvim-ts-rainbow2' },
  },
  {
    'windwp/nvim-ts-autotag',
    ft = { 'typescriptreact', 'javascript', 'javascriptreact', 'html', 'vue', 'svelte' },
    config = true,
  },
  {
    'nvim-treesitter/playground',
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
    dependencies = { 'nvim-treesitter' },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      rvim.highlight.plugin('treesitter-context', {
        { ContextBorder = { link = 'FloatBorder' } },
        { TreesitterContext = { inherit = 'Normal' } },
        { TreesitterContextLineNumber = { inherit = 'LineNr' } },
      })
      require('treesitter-context').setup({
        multiline_threshold = 4,
        separator = { '─', 'ContextBorder' }, --[[alernatives: ▁ ─ ▄ ]]
        mode = 'cursor',
      })
    end,
  },
}
