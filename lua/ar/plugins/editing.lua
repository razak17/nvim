local api = vim.api
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
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
        if get_cond('text-case.nvim', not minimal) then
          table.insert(keys or {}, {
            '<leader>ft',
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
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after', },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before', },
      { '<localleader>yp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after', },
      { '<localleader>yP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before', },
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
    cond = function() return get_cond('treesj', not minimal) end,
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
    'subnut/nvim-ghost.nvim',
    cond = function() return vim.env.RVIM_GHOST_ENABLED == '1' end,
    lazy = false,
    init = function()
      api.nvim_create_augroup('NvimGhostUserAutocommands', { clear = false })
      api.nvim_create_autocmd('User', {
        group = 'NvimGhostUserAutocommands',
        pattern = {
          'www.reddit.com',
          'www.github.com',
          'www.protectedtext.com',
          '*github.com',
        },
        command = 'setfiletype markdown',
      })
    end,
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
  ------------------------------------------------------------------------------
  -- Swap Text
  ------------------------------------------------------------------------------
  {
    'mizlan/iswap.nvim',
    cond = function() return get_cond('iswap.nvim', not minimal) end,
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },
  {
    'Wansmer/sibling-swap.nvim',
    -- stylua: ignore
    keys = {
      { '<leader>ih', function() require('sibling-swap').swap_with_left() end, desc = 'sibling-swap: swap left', },
      { '<leader>il', function() require('sibling-swap').swap_with_right() end, desc = 'sibling-swap: swap right', },
    },
    opts = {
      use_default_keymaps = false,
      highlight_node_at_cursor = true,
    },
  },
  ------------------------------------------------------------------------------
  -- Toggle Text
  ------------------------------------------------------------------------------
  {
    'nguyenvukhang/nvim-toggler',
    cond = function() return get_cond('nvim-toggler', not minimal) end,
    -- stylua: ignore
    keys = {
      { '<leader>ii', function() require("nvim-toggler").toggle() end, desc = 'nvim-toggler: toggle', },
    },
    opts = {
      remove_default_keybinds = true,
      inverses = {
        ['=='] = '~=',
        ['==='] = '!==',
        ['vim'] = 'emacs',
        ['let'] = 'const',
        ['margin'] = 'padding',
        ['-'] = '+',
        ['onClick'] = 'onSubmit',
        ['public'] = 'private',
        ['string'] = 'int',
        ['leader'] = 'localleader',
        ['chore'] = 'feat',
        ['double'] = 'single',
        ['config'] = 'opts',
        ['pre'] = 'post',
        ['column'] = 'row',
        ['before'] = 'after',
        ['end'] = 'start',
        ['high'] = 'low',
        ['open'] = 'close',
        ['and'] = 'or',
        ['GET'] = 'POST',
      },
    },
  },
  ------------------------------------------------------------------------------
  -- Sort
  ------------------------------------------------------------------------------
  {
    'sQVe/sort.nvim',
    cmd = { 'Sort' },
    -- stylua: ignore
    init = function()
      vim.g.whichkey_add_spec({'<localleader>S', group = 'Sort', mode = { 'n', 'x' }, })
    end,
    -- stylua: ignore
    keys = {
      { '<localleader>Ss', ':Sort<CR>', desc = 'sort: selection', mode = { 'n', 'x' }, silent = true },
      { '<localleader>SS', ':Sort!<CR>', desc = 'sort: selection (reverse)', mode = { 'n', 'x' }, silent = true },
      { '<localleader>Si', ':Sort i<CR>', desc = 'sort: ignore case', mode = { 'n', 'x' }, silent = true },
      { '<localleader>SI', ':Sort! i<CR>', desc = 'sort: ignore case (reverse)', mode = { 'n', 'x' }, silent = true },
    },
  },
  {
    'mtrajano/tssorter.nvim',
    -- stylua: ignore
    keys = {
      { '<leader>is', function() require('tssorter').sort() end, desc = 'tssorter: sort' },
      { '<leader>iS', function() require('tssorter').sort({ reverse = true }) end, desc = 'tssorter: reverse sort' },
    },
    opts = {},
  },
  ------------------------------------------------------------------------------
  -- Scratch Pads
  ------------------------------------------------------------------------------
  {
    'LintaoAmons/scratch.nvim',
    cmd = { 'Scratch', 'ScratchPad', 'ScratchOpen' },
    keys = { { '<c-w>O', ':Scratch<cr>', desc = 'scratch: new' } },
  },
  {
    'carbon-steel/detour.nvim',
    cond = function() return get_cond('detour.nvim', niceties) end,
    cmd = { 'Detour' },
    keys = { { '<c-w><enter>', ':Detour<cr>', desc = 'detour: toggle' } },
  },
  ------------------------------------------------------------------------------
  -- Edit Code Blocks
  ------------------------------------------------------------------------------
  {
    'dawsers/edit-code-block.nvim',
    cond = function() return get_cond('edit-code-block.nvim', not minimal) end,
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    opts = { wincmd = 'split' },
  },
  {
    'haolian9/nag.nvim',
    cond = function() return get_cond('nag.nvim', not minimal) end,
    dependencies = { 'haolian9/infra.nvim' },
    init = function()
      vim.g.whichkey_add_spec({
        '<localleader>n',
        group = 'Nag',
        mode = { 'x' },
      })
    end,
    -- stylua: ignore
    keys = {
      { mode = 'x', '<localleader>nv', ":lua require'nag'.split('right')<CR>", desc = 'nag: split right', },
      { mode = 'x', '<localleader>ns', ":lua require'nag'.split('below')<CR>", desc = 'nag: split below', },
      { mode = 'x', '<localleader>nt', ":lua require'nag'.tab()<CR>", desc = 'nag: split tab', },
    },
  },
}
