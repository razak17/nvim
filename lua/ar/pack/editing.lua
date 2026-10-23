ar.pack.add({
  {
    src = 'https://github.com/gbprod/yanky.nvim',
    cond = function() return ar.get_plugin_cond('yanky.nvim') end,
    init = function()
      vim.g.whichkey_add_spec({
        '<C-w>y',
        group = 'Yanky',
        mode = { 'n', 'x' },
      })
      ar.highlight.plugin('treehopper', {
        { YankyYanked = { link = 'IncSearch' } },
      })
    end,
    cmd = { 'YankyRingHistory' },
    -- stylua: ignore
    keys = {
      { '<C-w>p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after' },
      { '<C-w>P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before' },
      { '<C-w>yp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after' },
      { '<C-w>yP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before' },
      { '<C-w>yy', '<Plug>(YankyYank)', desc = 'yanky: yank text' },
      { '<C-w>yn', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      { '<C-w>yb', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      { '<C-w>yo', '<Cmd>YankyRingHistory<CR>', desc = 'yanky: open yank history' },
    },
    setup = function()
      require('yanky').setup({ ring = { storage = 'sqlite' } })
    end,
    dependencies = {
      { src = 'https://github.com/kkharji/sqlite.lua' },
    },
  },
  {
    src = 'https://github.com/Wansmer/treesj',
    cond = function() return ar.get_plugin_cond('treesj', ar.plugins.coding) end,
    cmd = { 'TSJSplit', 'TSJJoin' },
    keys = {
      { '<leader>oK', '<Cmd>TSJToggle<CR>', desc = 'split/join lines' },
      { 'gS', '<Cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<Cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    setup = function()
      local opts = {
        use_default_keymaps = false,
        cursor_behavior = 'start',
        max_join_length = math.huge,
      }
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
    src = 'https://github.com/hinell/duplicate.nvim',
    cond = function()
      return ar.get_plugin_cond('duplicate.nvim', not ar.plugins.minimal)
    end,
    cmd = { 'LineDuplicate', 'VisualDuplicate' },
    -- stylua: ignore
    keys = {
      { '<leader><leader>j', '<Cmd>LineDuplicate -1<CR>', desc = 'duplicate: line up' },
      { '<leader><leader>k', '<Cmd>LineDuplicate +1<CR>', desc = 'duplicate: line down' },
      { '<leader><leader>j', '<Cmd>VisualDuplicate -1<CR>', desc = 'duplicate: selection down', mode = 'x' },
      { '<leader><leader>k', '<Cmd>VisualDuplicate +1<CR>', desc = 'duplicate: selection down', mode = 'x' },
    },
  },
  {
    src = 'https://github.com/mfussenegger/nvim-treehopper',
    cond = function()
      return ar.get_plugin_cond('nvim-treehopper', not ar.plugins.minimal)
    end,
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
        function() require('tsht').nodes() end,
        desc = 'treehopper: toggle',
        mode = 'x',
        silent = true,
      },
    },
    setup = function()
      ar.highlight.plugin('treehopper', {
        { TSNodeKey = { link = 'MCursor' } },
      })
    end,
  },
  {
    src = 'https://github.com/max397574/better-escape.nvim',
    cond = function()
      return ar.get_plugin_cond('better-escape.nvim', not ar.plugins.minimal)
    end,
    event = { 'InsertEnter' },
    setup = function()
      require('better_escape').setup({
        default_mappings = false,
        mappings = {
          i = { j = { k = '<Esc>' } },
        },
      })
    end,
  },
})
