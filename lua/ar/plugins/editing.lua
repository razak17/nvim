local api = vim.api
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties
local get_cond = ar.get_plugin_cond

return {
  {
    'johmsalas/text-case.nvim',
    cond = function() return get_cond('text-case.nvim', not minimal) end,
    opts = { default_keymappings_enabled = false },
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
    'monaqa/dial.nvim',
    cond = function() return get_cond('dial.nvim', not minimal) end,
    keys = {
      {
        '<C-a>',
        function() require('dial.map').manipulate('increment', 'normal') end,
        desc = 'dial: increment',
      },
      {
        '<C-x>',
        function() require('dial.map').manipulate('decrement', 'normal') end,
        desc = 'dial: decrement',
      },
      {
        'g<C-a>',
        function() require('dial.map').manipulate('increment', 'gnormal') end,
        desc = 'dial: gincrement',
      },
      {
        'g<C-x>',
        function() require('dial.map').manipulate('decrement', 'gnormal') end,
        desc = 'dial: gdecrement',
      },
      {
        mode = { 'x' },
        '<C-a>',
        function() require('dial.map').manipulate('increment', 'visual') end,
        desc = 'dial: vincrement',
      },
      {
        mode = { 'x' },
        '<C-x>',
        function() require('dial.map').manipulate('decrement', 'visual') end,
        desc = 'dial: vdecrement',
      },
      {
        mode = { 'x' },
        'g<C-a>',
        function() require('dial.map').manipulate('increment', 'gvisual') end,
        desc = 'dial: gvincrement',
      },
      {
        mode = { 'x' },
        'g<C-x>',
        function() require('dial.map').manipulate('decrement', 'gvisual') end,
        desc = 'dial: gvdecrement',
      },
    },
    config = function()
      local augend = require('dial.augend')
      local config = require('dial.config')

      local operators = augend.constant.new({
        elements = { '&&', '||' },
        word = false,
        cyclic = true,
      })

      config.augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias['%Y/%m/%d'],
        },
      })

      config.augends:on_filetype({
        go = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          operators,
        },
        typescript = { augend.integer.alias.decimal, augend.integer.alias.hex },
        markdown = {
          augend.integer.alias.decimal,
          augend.misc.alias.markdown_header,
        },
        yaml = {
          augend.integer.alias.decimal,
          augend.semver.alias.semver,
        },
        toml = {
          augend.integer.alias.decimal,
          augend.semver.alias.semver,
        },
      })
    end,
  },
  {
    'altermo/ultimate-autopair.nvim',
    cond = function() return get_cond('ultimate-autopair.nvim', false) end,
    event = { 'InsertEnter', 'CmdlineEnter' },
    init = function()
      ar.augroup('UltimateAutoPair', {
        event = { 'RecordingEnter' },
        command = function() require('ultimate-autopair').disable() end,
      }, {
        event = { 'RecordingLeave' },
        command = function() require('ultimate-autopair').enable() end,
      })
      ar.add_to_select_menu('command_palette', {
        ['Toggle Auto-pairing'] = function()
          require('ultimate-autopair').toggle()
          local mode = require('ultimate-autopair').isenabled() and 'enabled'
            or 'disabled'
          vim.notify(mode, nil, { title = 'Auto-pairing', icon = '' })
        end,
      })
    end,
    -- https://github.com/chrisgrieser/.config/blob/788aa7dc619410086e972d6da4177af29827d3e9/nvim/lua/plugin-specs/ultimate-autopair.lua?plain=1#L30
    opts = {
      bs = {
        space = 'balance',
        cmap = false, -- keep my `<BS>` mapping for the cmdline
      },
      fastwarp = {
        map = '<M-f>',
        rmap = '<M-F>', -- backwards
        hopout = true,
        nocursormove = true,
        multiline = false,
      },
      cr = { autoclose = false },
      tabout = { enable = false, map = '<Nop>' },
      extensions = { -- disable in these filetypes
        filetype = {
          nft = { 'TelescopePrompt', 'snacks_picker_input', 'rip-substitute' },
        },
      },
      config_internal_pairs = {
        { "'", "'", nft = { 'markdown', 'gitcommit' } }, -- used as apostrophe
        { '"', '"', nft = { 'vim' } }, -- uses as comments in vimscript
        { -- disable codeblocks, see https://github.com/Saghen/blink.cmp/issues/1692
          '`',
          '`',
          cond = function()
            local mdCodeblock = vim.bo.ft == 'markdown'
              and api.nvim_get_current_line():find('^[%s`]*$')
            return not mdCodeblock
          end,
        },
        { '```', '```', nft = { 'markdown' } },
      },
      -- INFO custom keys need to be "appended" to the opts as a list
      { '**', '**', ft = { 'markdown' } }, -- bold
      { [[\"]], [[\"]], ft = { 'zsh', 'json', 'applescript' } }, -- escaped quote
      -- commit scope (= only first word) for commit messages
      {
        '(',
        '): ',
        ft = { 'gitcommit' },
        cond = function(_) return not api.nvim_get_current_line():find(' ') end,
      },
      -- for keymaps like `<C-a>`
      { '<', '>', ft = { 'vim' } },
      {
        '<',
        '>',
        ft = { 'lua' },
        cond = function(fn)
          -- FIX https://github.com/altermo/ultimate-autopair.nvim/issues/88
          local in_lua_lua =
            vim.endswith(api.nvim_buf_get_name(0), '/ftplugin/lua.lua')
          return not in_lua_lua and fn.in_string()
        end,
      },
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
    'windwp/nvim-autopairs',
    cond = function()
      local condition = not minimal
        and ar_config.completion.variant ~= 'omnifunc'
      return get_cond('nvim-autopairs', condition)
    end,
    event = 'InsertEnter',
    config = function()
      local autopairs = require('nvim-autopairs')
      if ar.completion.enable then
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      end
      autopairs.setup({
        close_triple_quotes = true,
        disable_filetype = { 'neo-tree-popup' },
        check_ts = true,
        fast_wrap = { map = '<c-e>' },
        ts_config = {
          lua = { 'string' },
          dart = { 'string' },
          javascript = { 'template_string' },
        },
      })
    end,
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
    cond = function()
      return get_cond('nvim-ghost.nvim', ar.plugins.overrides.ghost_text.enable)
    end,
    lazy = not ar.plugins.overrides.ghost_text.enable,
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
    init = function()
      vim.g.whichkey_add_spec({
        '<localleader>S',
        group = 'Sort',
        mode = { 'x' },
      })
    end,
    keys = {
      {
        '<localleader>Ss',
        '<Cmd>Sort<CR>',
        desc = 'sort: selection',
        mode = { 'x' },
        silent = true,
      },
      {
        '<localleader>SS',
        '<Cmd>Sort!<CR>',
        desc = 'sort: selection (reverse)',
        mode = { 'x' },
        silent = true,
      },
      {
        '<localleader>Si',
        '<Cmd>Sort i<CR>',
        desc = 'sort: ignore case',
        mode = { 'x' },
        silent = true,
      },
      {
        '<localleader>SI',
        '<Cmd>Sort! i<CR>',
        desc = 'sort: ignore case (reverse)',
        mode = { 'x' },
        silent = true,
      },
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
  --------------------------------------------------------------------------------
  -- Disabled
  --------------------------------------------------------------------------------
  {
    'HiPhish/rainbow-delimiters.nvim',
    enabled = false,
    cond = function() return get_cond('rainbow-delimiters.nvim', niceties) end,
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      local rainbow_delimiters = require('rainbow-delimiters')

      vim.g.rainbow_delimiters = {
        blacklist = { 'svelte' },
        strategy = {
          [''] = rainbow_delimiters.strategy['global'],
        },
        query = {
          [''] = 'rainbow-delimiters',
        },
      }
    end,
  },
  {
    'gabrielpoca/replacer.nvim',
    cond = function() return get_cond('replacer.nvim', false) end,
    opts = { rename_files = false },
    -- stylua: ignore
    keys = {
      { '<leader>oh', function() require('replacer').run() end, desc = 'replacer: run' },
      { '<leader>os', function() require('replacer').save() end, desc = 'replacer: save' },
    },
  },
  {
    'Wansmer/binary-swap.nvim',
    cond = false,
    -- stylua: ignore
    keys = {
      { '<leader>iA', function() require('binary-swap').swap_operands() end, desc = 'binary-swap: swap' },
      { '<leader>iB', function() require('binary-swap').swap_operands_with_operator() end, desc = 'binary-swap: swap with operator' },
    },
  },
  {
    'al-ce/opptogg.nvim',
    cond = false,
    cmd = { 'OppTogg' },
    keys = {
      { '<leader>io', '<cmd>OppTogg<CR>', desc = 'opptogg: toggle' },
    },
    opts = {},
    opp_table = {
      ['true'] = 'false',
      ['yes'] = 'no',
      ['foo'] = 'bar',
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
    },
  },
  {
    desc = 'readline style keybindings in insert mode',
    'tpope/vim-rsi',
    enabled = false,
    cond = function() return get_cond('vim-rsi', not minimal) end,
    event = { 'InsertEnter' },
  },
  {
    'kelvinauta/focushere.nvim',
    cond = false,
    cmd = { 'FocusHere', 'FocusClear' },
    -- stylua: ignore
    keys = {
      { '<leader>of', ':FocusHere<CR>', desc = 'focus: here', silent = true, mode = { 'v' } },
      { '<leader>of', ':FocusClear<CR>', desc = 'focus: clear', silent = true, mode = { 'n' } },
    },
    opts = {},
  },
}
