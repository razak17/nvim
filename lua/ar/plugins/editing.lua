local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  { 'tpope/vim-rsi', cond = not minimal, event = { 'InsertEnter' } },
  {
    'johmsalas/text-case.nvim',
    cond = not minimal,
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
    cond = not minimal,
    cmd = { 'YankyRingHistory' },
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
    opts = { ring = { storage = 'sqlite' } },
  },
  {
    'hinell/duplicate.nvim',
    cond = not minimal,
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
    cond = not minimal,
    keys = {
      {
        mode = { 'n' },
        '<C-a>',
        function() require('dial.map').manipulate('increment', 'normal') end,
        desc = 'dial: increment',
      },
      {
        mode = { 'n' },
        '<C-x>',
        function() require('dial.map').manipulate('decrement', 'normal') end,
        desc = 'dial: decrement',
      },
      {
        mode = { 'n' },
        'g<C-a>',
        function() require('dial.map').manipulate('increment', 'gnormal') end,
        desc = 'dial: gincrement',
      },
      {
        mode = { 'n' },
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
    cond = not minimal,
    event = { 'InsertEnter', 'CmdlineEnter' },
    -- stylua: ignore
    keys = {
      -- Open new scope (`remap` to trigger auto-pairing)
      { '<localleader>os', 'a{<CR>', desc = 'ultimate-autopair: open new scope', remap = true },
      { '<localleader>os', '{<CR>', mode = 'i', desc = 'ultimate-autopair: open new scope', remap = true },
    },
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
      cr = { autoclose = true },
      space = { enable = true },
      space2 = { enable = true },
      config_internal_pairs = {
        { "'", "'", nft = { 'markdown' } }, -- since used as apostrophe
        { '"', '"', nft = { 'vim' } }, -- vimscript uses quotes as comments
      },
      -- INFO custom keys need to be "appended" to the opts as a list
      { '**', '**', ft = { 'markdown' } }, -- bold
      { [[\"]], [[\"]], ft = { 'zsh', 'json', 'applescript' } }, -- escaped quote

      { -- commit scope (= only first word) for commit messages
        '(',
        '): ',
        ft = { 'gitcommit' },
        cond = function(_) return not vim.api.nvim_get_current_line():find(' ') end,
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
            vim.endswith(vim.api.nvim_buf_get_name(0), '/ftplugin/lua.lua')
          return not in_lua_lua and fn.in_string()
        end,
      },
    },
  },
  {
    'AgusDOLARD/backout.nvim',
    opts = {},
    keys = {
      -- stylua: ignore
      { '<M-b>', "<Cmd>lua require('backout').back()<CR>", mode = { 'i', 'c' } },
      { '<M-n>', "<Cmd>lua require('backout').out()<CR>", mode = { 'i', 'c' } },
    },
  },
  {
    'windwp/nvim-autopairs',
    cond = false,
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
    cond = not minimal,
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
                bg = { from = 'qfLineNr', attr = 'fg' },
              },
            },
          },
        },
      })
    end,
  },
  {
    'danymat/neogen',
    cond = not minimal,
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
    cond = not minimal,
    -- stylua: ignore
    keys = {
      { '<leader>K', function() require('ts-node-action').node_action() end, desc = 'ts-node-action: run', },
    },
    opts = {},
  },
  {
    'Wansmer/treesj',
    cond = not minimal,
    keys = {
      {
        'gS',
        '<cmd>TSJSplit<CR>',
        desc = 'split to multiple lines',
      },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    cond = not minimal,
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
    'HiPhish/rainbow-delimiters.nvim',
    cond = niceties,
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
    'subnut/nvim-ghost.nvim',
    cond = ar.plugins.overrides.ghost_text.enable,
    lazy = not ar.plugins.overrides.ghost_text.enable,
  },
  {
    'gabrielpoca/replacer.nvim',
    opts = { rename_files = false },
    -- stylua: ignore
    keys = {
      { '<leader>oh', function() require('replacer').run() end, desc = 'replacer: run' },
      { '<leader>os', function() require('replacer').save() end, desc = 'replacer: save' },
    },
  },
  {
    'max397574/better-escape.nvim',
    cond = not minimal,
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
    cond = not minimal,
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
  {
    'Wansmer/binary-swap.nvim',
    cond = false,
    -- stylua: ignore
    keys = {
      { '<leader>iA', function() require('binary-swap').swap_operands() end, desc = 'binary-swap: swap' },
      { '<leader>iB', function() require('binary-swap').swap_operands_with_operator() end, desc = 'binary-swap: swap with operator' },
    },
  },
  ------------------------------------------------------------------------------
  -- Toggle Text
  ------------------------------------------------------------------------------
  {
    'nguyenvukhang/nvim-toggler',
    cond = not minimal,
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
    cond = niceties,
    cmd = { 'Detour' },
    keys = { { '<c-w><enter>', ':Detour<cr>', desc = 'detour: toggle' } },
  },
  ------------------------------------------------------------------------------
  -- Edit Code Blocks
  ------------------------------------------------------------------------------
  {
    'dawsers/edit-code-block.nvim',
    cond = not minimal,
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    opts = { wincmd = 'split' },
  },
  {
    'haolian9/nag.nvim',
    cond = not minimal,
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
