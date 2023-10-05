local highlight = rvim.highlight

return {
  {
    'nvim-treesitter/nvim-treesitter',
    cond = rvim.treesitter.enable,
    event = 'BufReadPost',
    build = ':TSUpdate',
    keys = {
      {
        'R',
        '<cmd>edit | TSBufEnable highlight<CR>',
        desc = 'treesitter: enable highlight',
      },
    },
    config = function()
      require('nvim-treesitter.configs').setup({
        auto_install = true,
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats =
              pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
          additional_vim_regex_highlighting = { 'org', 'sql' },
        },
        context_commentstring = { enable = true, enable_autocmd = false },
        incremental_selection = {
          enable = false,
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
              ['if'] = {
                query = '@function.inner',
                desc = 'ts: inner function',
              },
              ['ac'] = { query = '@class.outer', desc = 'ts: all class' },
              ['ic'] = { query = '@class.inner', desc = 'ts: inner class' },
              ['aC'] = {
                query = '@conditional.outer',
                desc = 'ts: all conditional',
              },
              ['iC'] = {
                query = '@conditional.inner',
                desc = 'ts: inner conditional',
              },
              ['aH'] = {
                query = '@assignment.lhs',
                desc = 'ts: assignment lhs',
              },
              ['aL'] = {
                query = '@assignment.rhs',
                desc = 'ts: assignment rhs',
              },
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
          lsp_interop = { enable = false },
        },
        indent = { enable = { 'javascriptreact' } },
        matchup = {
          enable = true,
          enable_quotes = true,
          disable_virtual_text = true,
          disable = { 'c', 'python' },
        },
        autotag = { enable = true },
        tree_setter = { enable = true },
        query_linter = {
          enable = true,
          use_virtual_text = false,
          lint_events = { 'BufWrite', 'CursorHold' },
        },
        playground = { persist_queries = true },
        ensure_installed = {
          'c',
          'vim',
          'vimdoc',
          'query',
          'lua',
          'luadoc',
          'luap',
          'diff',
          'regex',
          'gitcommit',
          'git_config',
          'git_rebase',
          'markdown',
          'markdown_inline',
        },
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
    },
  },
  {
    'windwp/nvim-ts-autotag',
    cond = rvim.treesitter.enable,
    ft = {
      'typescriptreact',
      'javascript',
      'javascriptreact',
      'html',
      'vue',
      'svelte',
    },
  },
  {
    'nvim-treesitter/playground',
    cond = rvim.treesitter.enable,
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    cond = rvim.treesitter.enable,
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      highlight.plugin('treesitter-context', {
        { TreesitterContextSeparator = { link = 'VertSplit' } },
        { TreesitterContext = { inherit = 'Normal' } },
        { TreesitterContextLineNumber = { inherit = 'LineNr' } },
      })
      require('treesitter-context').setup({
        multiline_threshold = 4,
        separator = '─', -- alternatives: ▁ ─ ▄
        mode = 'cursor',
      })
    end,
  },
  {
    'andymass/vim-matchup',
    event = { 'BufReadPre', 'BufNewFile' },
    cond = rvim.treesitter.enable,
    keys = {
      { '[[', '<plug>(matchup-[%)', mode = { 'n', 'x' } },
      { ']]', '<plug>(matchup-]%)', mode = { 'n', 'x' } },
      {
        '<localleader>lw',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
    config = function()
      highlight.plugin('vim-matchup', {
        { MatchWord = { inherit = 'LspReferenceText', underline = true } },
        { MatchParenCursor = { link = 'MatchParen' } },
        { MatchParenOffscreen = { link = 'MatchParen' } },
      })
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_nomode = 'i'
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_matchparen_deferred_show_delay = 400
      vim.g.matchup_matchparen_deferred_hide_delay = 400
      vim.g.matchup_matchparen_offscreen = {}
    end,
  },
  {
    'sustech-data/wildfire.nvim',
    cond = rvim.treesitter.enable,
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
  {
    'filNaj/tree-setter',
    cond = rvim.treesitter.enable,
    event = 'VeryLazy',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
}
