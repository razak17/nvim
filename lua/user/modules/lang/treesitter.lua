return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    config = function()
      -- This option, which currently doesn't work upstream, disables linking treesitter highlights
      -- to the new capture highlights which color schemes and plugins depend on. By toggling it
      -- I can see which highlights still need to be supported in upstream plugins.
      -- NOTE: this is currently broken, do not set to true
      vim.g.skip_ts_default_groups = false

      local status_ok, treesitter_configs = rvim.safe_require('nvim-treesitter.configs')
      if not status_ok then return end

      treesitter_configs.setup({
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        context_commentstring = {
          enable = true,
          enable_autocmd = false,
        },
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
          select = {
            enable = true,
            lookahead = true,
            include_surrounding_whitespace = true,
            keymaps = {
              ['af'] = { query = '@function.outer', desc = 'ts: all function' },
              ['if'] = { query = '@function.inner', desc = 'ts: inner function' },
              ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
              ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
              ['aC'] = { query = '@conditional.outer', desc = 'ts: all conditional' },
              ['iC'] = { query = '@conditional.inner', desc = 'ts: inner conditional' },
              ['aL'] = { query = '@assignment.lhs', desc = 'ts: assignment lhs' },
              ['aR'] = { query = '@assignment.rhs', desc = 'ts: assignment rhs' },
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
            enable = false,
          },
        },
        indent = { enable = { 'javascriptreact' } },
        matchup = { enable = true, disable = { 'c', 'python' } },
        rainbow = {
          enable = true,
          colors = { 'royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3' },
        },
        query_linter = {
          enable = true,
          use_virtual_text = false,
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

      map(
        'n',
        'R',
        '<cmd>edit | TSBufEnable highlight<CR>',
        { desc = 'treesitter: enable highlight' }
      )
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'mrjones2014/nvim-ts-rainbow',
    },
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
        mode = 'topline',
      })
    end,
  },
}
