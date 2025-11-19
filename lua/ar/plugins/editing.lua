local coding = ar.plugins.coding
local minimal = ar.plugins.minimal
local get_cond = ar.get_plugin_cond

return {
  {
    {
      'johmsalas/text-case.nvim',
      cond = function() return get_cond('text-case.nvim', not minimal) end,
      opts = { default_keymappings_enabled = false },
    },
    {
      'nvim-telescope/telescope.nvim',
      optional = true,
      keys = function(_, keys)
        if
          get_cond('text-case.nvim', not minimal)
          and ar_config.picker.variant == 'telescope'
        then
          table.insert(keys or {}, {
            '<leader>fW',
            function()
              require('telescope').extensions.textcase.normal_mode(
                ar.telescope.minimal_ui()
              )
            end,
            desc = 'textcase',
          })
        end
      end,
      opts = function(_, opts)
        return get_cond('text-case.nvim', not minimal)
            and vim.g.telescope_add_extension({ 'textcase' }, opts)
          or opts
      end,
    },
  },
  {
    'gbprod/yanky.nvim',
    init = function()
      vim.g.whichkey_add_spec({
        '<localleader>y',
        group = 'Yanky',
        mode = { 'n', 'x' },
      })
    end,
    cond = function() return get_cond('yanky.nvim', not minimal) end,
    -- stylua: ignore
    keys = {
      { mode = { 'n', 'x' }, 'p', '<Plug>(YankyPutAfter)', desc = 'yanky: put after', },
      { mode = { 'n', 'x' }, 'P', '<Plug>(YankyPutBefore)', desc = 'yanky: put before', },
      { mode = { 'n', 'x' }, '<localleader>yp', '<Plug>(YankyGPutAfter)', desc = 'yanky: gput after', },
      { mode = { 'n', 'x' }, '<localleader>yP', '<Plug>(YankyGPutBefore)', desc = 'yanky: gput before', },
      { '<localleader>yy', '<Plug>(YankyYank)', desc = 'yanky: yank Text' },
      { '<localleader>yn', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      { '<localleader>yb', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      { '<localleader>yo', '<Cmd>YankyRingHistory<CR>', desc = 'yanky: open yank history', },
    },
    cmd = { 'YankyRingHistory' },
    opts = { ring = { storage = 'sqlite' } },
    config = function(_, opts)
      ar.highlight.plugin('treehopper', {
        theme = {
          ['onedark'] = { { YankyYanked = { link = 'IncSearch' } } },
        },
      })
      require('yanky').setup(opts)
    end,
    dependencies = 'kkharji/sqlite.lua',
  },
  {
    desc = 'Duplicate visual selection, lines, and textobjects',
    'hinell/duplicate.nvim',
    cond = function() return get_cond('duplicate.nvim', not minimal) end,
    cmd = { 'LineDuplicate', 'VisualDuplicate' },
    -- stylua: ignore
    keys = {
      { '<leader><leader>j', '<Cmd>LineDuplicate -1<CR>', desc = 'duplicate: line up' },
      { '<leader><leader>k', '<Cmd>LineDuplicate +1<CR>', desc = 'duplicate: line down' },
      { mode = 'x', '<leader><leader>j', '<Cmd>VisualDuplicate -1<CR>', desc = 'duplicate: selection down' },
      {  mode = 'x','<leader><leader>k', '<Cmd>VisualDuplicate +1<CR>', desc = 'duplicate: selection down' },
    },
  },
  {
    'AgusDOLARD/backout.nvim',
    cond = function() return get_cond('backout.nvim', not minimal) end,
    opts = {},
    keys = {
      -- stylua: ignore
      { '<M-b>', "<Cmd>lua require('backout').back()<CR>", mode = { 'i', 'c' } },
      { '<M-n>', "<Cmd>lua require('backout').out()<CR>", mode = { 'i', 'c' } },
    },
  },
  {
    'mfussenegger/nvim-treehopper',
    cond = function() return get_cond('nvim-treehopper', not minimal) end,
    keys = {
      {
        'u',
        function() require('tsht').nodes() end,
        desc = 'treehopper: toggle',
        mode = 'o',
        noremap = false,
        silent = true,
      },
      {
        'u',
        ":lua require('tsht').nodes()<CR>",
        desc = 'treehopper: toggle',
        mode = 'x',
        silent = true,
      },
    },
    config = function()
      ar.highlight.plugin('treehopper', {
        theme = {
          ['onedark'] = {
            {
              TSNodeKey = {
                fg = { from = 'VertSplit', attr = 'fg', alter = -0.2 },
                bg = { from = 'WildMenu', attr = 'fg', alter = 1.2 },
              },
            },
          },
        },
      })
    end,
  },
  {
    'danymat/neogen',
    cond = function() return get_cond('neogen', not minimal) end,
    -- stylua: ignore
    keys = {
      { '<localleader>nd', function() require('neogen').generate() end, desc = 'neogen: generate doc', },
      { '<localleader>nf', function() require('neogen').generate({ type = 'file' }) end, desc = 'neogen: file doc', },
      { '<localleader>nc', function() require('neogen').generate({ type = 'class' }) end, desc = 'neogen: class doc', },
      { '<localleader>nf', function() require('neogen').generate({ type = 'func' }) end, desc = 'neogen: func doc', },
      { '<localleader>nt', function() require('neogen').generate({ type = 'type' }) end, desc = 'neogen: type doc', },
    },
    opts = { snippet_engine = 'luasnip' },
  },
  {
    'ckolkey/ts-node-action',
    cond = function() return get_cond('ts-node-action', not minimal) end,
    -- stylua: ignore
    keys = {
      { '<leader>K', function() require('ts-node-action').node_action() end, desc = 'ts-node-action: run', },
    },
    opts = {},
  },
  {
    'Wansmer/treesj',
    cond = function() return get_cond('treesj', coding) end,
    -- stylua: ignore
    keys = {
      { '<leader>oK', function() require('treesj').toggle() end, desc = 'split-join lines' },
      { '<leader>oK', 'gw}', ft = 'markdown', desc = 'reflow rest of paragraph' },
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = {
      use_default_keymaps = false,
      cursor_behavior = 'start',
      max_join_length = math.huge,
    },
    config = function(_, opts)
      local gww =
        { both = { fallback = function() vim.cmd('normal! gww') end } }
      local joinWithoutCurly = {
        -- remove curly brackets in js when joining if statements https://github.com/Wansmer/treesj/issues/150
        statement_block = {
          join = {
            format_tree = function(tsj)
              if tsj:tsnode():parent():type() == 'if_statement' then
                tsj:remove_child({ '{', '}' })
                tsj:update_preset({ recursive = false }, 'join')
              else
                require('treesj.langs.javascript').statement_block.join.format_tree(
                  tsj
                )
              end
            end,
          },
        },
        -- one-line-if-statement can be split into multi-line https://github.com/Wansmer/treesj/issues/150
        expression_statement = {
          join = { enable = false },
          split = {
            enable = function(tsn) return tsn:parent():type() == 'if_statement' end,
            format_tree = function(tsj) tsj:wrap({ left = '{', right = '}' }) end,
          },
        },
        return_statement = {
          join = { enable = false },
          split = {
            enable = function(tsn) return tsn:parent():type() == 'if_statement' end,
            format_tree = function(tsj) tsj:wrap({ left = '{', right = '}' }) end,
          },
        },
      }
      opts.langs = {
        comment = { source = gww, element = gww }, -- comments in any language
        lua = { comment = gww },
        jsdoc = { source = gww, description = gww },
        javascript = joinWithoutCurly,
        typescript = joinWithoutCurly,
        svelte = {
          ['quoted_attribute_value'] = {
            both = {
              enable = function(tsn) return tsn:parent():type() == 'attribute' end,
            },
            split = {
              format_tree = function(tsj)
                local str = tsj:child('attribute_value')
                local words = vim.split(str:text(), ' ')
                tsj:remove_child('attribute_value')
                for i, word in ipairs(words) do
                  tsj:create_child({ text = word }, i + 1)
                end
              end,
            },
            join = {
              format_tree = function(tsj)
                local str = tsj:child('attribute_value')
                local node_text = str:text()
                tsj:remove_child('attribute_value')
                tsj:create_child({ text = node_text }, 2)
              end,
            },
          },
        },
      }
      require('treesj').setup(opts)
    end,
  },
  {
    'ThePrimeagen/refactoring.nvim',
    cond = function() return get_cond('refactoring.nvim', not minimal) end,
    -- stylua: ignore
    init = function()
      vim.g.whichkey_add_spec({ '<leader><leader>r', desc = 'Refactoring', mode = { 'n', 'x' } })
    end,
    keys = {
      {
        '<leader><leader>ro',
        function() require('telescope').extensions.refactoring.refactors() end,
        desc = 'refactoring: open',
        mode = { 'n', 'x' },
      },
      {
        '<leader><leader>rk',
        function() require('refactoring').select_refactor() end,
        desc = 'refactoring: select refactor',
        mode = { 'n', 'x' },
      },
      {
        '<leader><leader>rf',
        function() require('refactoring').debug.printf({ below = false }) end,
        desc = 'refactoring: Insert printf statement',
      },
      {
        '<leader><leader>rp',
        function() require('refactoring').debug.print_var({ normal = true }) end,
        desc = 'refactoring: insert print statement',
      },
      {
        '<leader><leader>rp',
        function() require('refactoring').debug.print_var({}) end,
        desc = 'refactoring: insert print statement',
        mode = { 'x' },
      },
      {
        '<leader><leader>rc',
        function() require('refactoring').debug.cleanup() end,
        desc = 'refactoring: cleanup debug statements',
      },
    },
    opts = {},
  },
  {
    'max397574/better-escape.nvim',
    cond = function() return get_cond('better-escape.nvim', not minimal) end,
    event = { 'InsertEnter' },
    opts = {
      default_mappings = false,
      mappings = {
        i = {
          j = { k = '<Esc>' },
        },
      },
    },
    config = function(_, opts) require('better_escape').setup(opts) end,
  },
}
