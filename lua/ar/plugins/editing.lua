local border = ar.ui.current.border
local minimal, niceties = ar.plugins.minimal, ar.plugins.niceties

return {
  {
    'johmsalas/text-case.nvim',
    cond = not minimal,
    opts = { default_keymappings_enabled = false },
  },
  {
    'gbprod/yanky.nvim',
    init = function()
      require('which-key').add({
        { '<localleader>y', group = 'Yanky' },
      })
      require('which-key').add({
        mode = { 'x' },
        { '<localleader>y', group = 'Yanky' },
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
    event = 'VeryLazy',
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
    opts = {},
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
    init = function()
      require('which-key').add({
        { '<leader><leader>r', group = 'Refactoring' },
      })
      require('which-key').add({
        mode = { 'x' },
        { '<leader><leader>r', group = 'Refactoring' },
      })
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
    'smoka7/multicursors.nvim',
    cond = not minimal,
    opts = {
      hint_config = { border = border },
    },
    cmd = {
      'MCstart',
      'MCvisual',
      'MCclear',
      'MCpattern',
      'MCvisualPattern',
      'MCunderCursor',
    },
    keys = {
      {
        '<M-e>',
        '<cmd>MCstart<cr>',
        mode = { 'v', 'n' },
        desc = 'Create a selection for selected text or word under the cursor',
      },
    },
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
    event = { 'VeryLazy' },
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
      require('which-key').add({
        mode = { 'x' },
        { '<localleader>S', group = 'Sort' },
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
      require('which-key').add({
        mode = { 'x' },
        { '<localleader>n', group = 'Nag' },
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
