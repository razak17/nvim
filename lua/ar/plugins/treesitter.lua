local highlight = ar.highlight
local minimal = ar.plugins.minimal
local ts_enabled = ar.treesitter.enable

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPost',
    build = ':TSUpdate',
    keys = {
      {
        '<localleader>R',
        '<cmd>edit | TSBufEnable highlight<CR>',
        desc = 'treesitter: enable highlight',
      },
    },
    opts = {
      auto_install = true,
      highlight = {
        enable = true,
        disable = function(_, buf)
          local enable = ar.treesitter.enable
          if not enable and vim.bo.ft ~= 'lua' then return true end

          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats =
            pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then return true end
        end,
        additional_vim_regex_highlighting = { 'org', 'sql' },
      },
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
        select = {
          enable = not minimal,
          lookahead = true,
          include_surrounding_whitespace = true,
          -- stylua: ignore
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
            ["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
            ["L="] = { query = "@assignment.lhs", desc = "Select left hand side of an assignment" },
            ["R="] = { query = "@assignment.rhs", desc = "Select right hand side of an assignment" },

            -- works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
            ["a:"] = { query = "@property.outer", desc = "Select outer part of an object property" },
            ["i:"] = { query = "@property.inner", desc = "Select inner part of an object property" },
            ["L:"] = { query = "@property.lhs", desc = "Select left part of an object property" },
            ["R:"] = { query = "@property.rhs", desc = "Select right part of an object property" },

            -- NOTE: mii.ai does same things
            -- ["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
            -- ["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },

            -- ["ao"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            -- ["io"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },

            -- ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            -- ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },

            -- ["au"] = { query = "@call.outer", desc = "Select outer part of a function call" },
            -- ["iu"] = { query = "@call.inner", desc = "Select inner part of a function call" },

            -- ["af"] = { query = "@function.outer", desc = "Select outer part of a method/function definition" },
            -- ["if"] = { query = "@function.inner", desc = "Select inner part of a method/function definition" },

            -- ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            -- ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
          },
        },
        -- stylua: ignore
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
      indent = { enable = true },
      matchup = {
        enable = true,
        enable_quotes = true,
        disable_virtual_text = true,
        disable = { 'c', 'python' },
      },
      tree_setter = { enable = true },
      query_linter = {
        enable = true,
        use_virtual_text = false,
        lint_events = { 'BufWrite', 'CursorHold' },
      },
      playground = { persist_queries = true },
        -- stylua: ignore
        ensure_installed = {
          'c', 'vim', 'vimdoc', 'query', 'lua', 'luadoc', 'luap', 'diff', 'regex',
          'gitcommit', 'git_config', 'git_rebase', 'markdown', 'markdown_inline',
        },
    },
    config = function(_, opts) require('nvim-treesitter.configs').setup(opts) end,
    dependencies = {
      {
        'nvim-treesitter/nvim-treesitter-textobjects',
        cond = not minimal,
        event = 'VeryLazy',
        config = function()
          -- ref: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/treesitter.lua?plain=1#L108
          -- When in diff mode, we want to use the default
          -- vim text objects c & C instead of the treesitter ones.
          local move = require('nvim-treesitter.textobjects.move') ---@type table<string,fun(...)>
          local configs = require('nvim-treesitter.configs')
          for name, fn in pairs(move) do
            if name:find('goto') == 1 then
              move[name] = function(q, ...)
                if vim.wo.diff then
                  local config = configs.get_module('textobjects.move')[name] ---@type table<string,string>
                  for key, query in pairs(config or {}) do
                    if q == query and key:find('[%]%[][cC]') then
                      vim.cmd('normal! ' .. key)
                      return
                    end
                  end
                end
                return fn(q, ...)
              end
            end
          end
        end,
        init = function()
          -- PERF: no need to load the plugin, if we only need its queries for mini.ai
          local plugin =
            require('lazy.core.config').spec.plugins['nvim-treesitter']
          local opts = require('lazy.core.plugin').values(plugin, 'opts', false)
          local enabled = false
          if opts.textobjects then
            for _, mod in ipairs({ 'move', 'select', 'swap', 'lsp_interop' }) do
              if opts.textobjects[mod] and opts.textobjects[mod].enable then
                enabled = true
                break
              end
            end
          end
          if not enabled then
            require('lazy.core.loader').disable_rtp_plugin(
              'nvim-treesitter-textobjects'
            )
          end
        end,
      },
      {
        'JoosepAlviste/nvim-ts-context-commentstring',
        cond = false,
        opts = { enable_autocmd = false },
        config = function(_, opts)
          vim.g.skip_ts_context_commentstring_module = true
          require('ts_context_commentstring').setup(opts)
        end,
      },
    },
  },
  {
    'windwp/nvim-ts-autotag',
    cond = not minimal and ts_enabled,
    ft = {
      'typescriptreact',
      'javascript',
      'javascriptreact',
      'html',
      'vue',
      'svelte',
    },
    opts = {},
  },
  {
    'nvim-treesitter/playground',
    cond = not minimal and ts_enabled,
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
  },
  {
    'nvim-treesitter/nvim-treesitter-context',
    cond = not minimal and ts_enabled,
    event = { 'BufRead', 'BufNewFile' },
    cmd = { 'TSContextEnable', 'TSContextDisable', 'TSContextToggle' },
    config = function()
      highlight.plugin('treesitter-context', {
        theme = {
          ['onedark'] = {
            { TreesitterContextSeparator = { link = 'VertSplit' } },
            { TreesitterContext = { inherit = 'Normal' } },
            { TreesitterContextLineNumber = { inherit = 'LineNr' } },
          },
        },
      })
      local ts_ctx = require('treesitter-context')
      ts_ctx.setup({
        multiline_threshold = 4,
        separator = '─', -- alternatives: ▁ ─ ▄
        mode = 'cursor',
      })
      map(
        'n',
        '[K',
        function() ts_ctx.go_to_context(vim.v.count1) end,
        { desc = 'goto context' }
      )
    end,
  },
  {
    'andymass/vim-matchup',
    event = { 'BufReadPre', 'BufNewFile' },
    cond = not minimal and ts_enabled,
    keys = {
      { '[[', '<plug>(matchup-[%)', mode = { 'n', 'x' } },
      { ']]', '<plug>(matchup-]%)', mode = { 'n', 'x' } },
      {
        '<localleader>lW',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treeitter** module to be loaded in time.
      -- Luckily, the only thins that those plugins need are the custom queries, which we make available
      -- during startup.
      require('lazy.core.loader').add_to_rtp(plugin)
      require('nvim-treesitter.query_predicates')
    end,
    config = function()
      highlight.plugin('vim-matchup', {
        theme = {
          ['onedark'] = {
            { MatchWord = { inherit = 'LspReferenceText', underline = true } },
            { MatchParenCursor = { link = 'MatchParen' } },
            { MatchParenOffscreen = { link = 'MatchParen' } },
          },
        },
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
    cond = not minimal and ts_enabled,
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },
  {
    'filNaj/tree-setter',
    enabled = false,
    cond = not minimal and false,
    event = 'VeryLazy',
  },
  {
    'andersevenrud/nvim_context_vt',
    cond = not minimal and ts_enabled,
    cmd = 'NvimContextVtToggle',
    keys = {
      {
        '<localleader>lb',
        '<cmd>NvimContextVtToggle<CR>',
        desc = 'toggle context visualizer',
      },
    },
    opts = {
      highlight = 'Comment',
    },
    init = function()
      ar.add_to_menu(
        'command_palette',
        { ['Toggle Context Visualizer'] = 'NvimContextVtToggle' }
      )
    end,
    config = function(_, opts)
      require('nvim_context_vt').setup(opts)
      vim.cmd([[NvimContextVtToggle]])
    end,
  },
  {
    'drybalka/tree-climber.nvim',
    enabled = false,
    cond = not minimal and false,
    keys = {
      {
        '<localleader>pK',
        function(opts) require('tree-climber').goto_parent(opts) end,
        mode = { 'n', 'o' },
      },
      {
        '<localleader>pL',
        function(opts) require('tree-climber').goto_next(opts) end,
        mode = { 'n', 'o' },
      },
      {
        '<localleader>pH',
        function(opts) require('tree-climber').goto_prev(opts) end,
        mode = { 'n', 'o' },
      },
      {
        '<localleader>pJ',
        function(opts) require('tree-climber').goto_child(opts) end,
        mode = { 'n', 'o' },
      },
    },
  },
}
