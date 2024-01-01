return {
  {
    'gbprod/yanky.nvim',
    cmd = { 'YankyRingHistory' },
    -- stylua: ignore
    keys = {
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after', },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before', },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after', },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before', },
      -- { '<m-n>', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      -- { '<m-p>', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      { '<localleader>y', '<Cmd>YankyRingHistory<CR>', desc = 'yanky: open yank history', },
    },
    opts = { ring = { storage = 'sqlite' } },
    dependencies = { 'kkharji/sqlite.lua' },
  },
  {
    'monaqa/dial.nvim',
    keys = {
      { '<C-a>', '<Plug>(dial-increment)', mode = 'n' },
      { '<C-x>', '<Plug>(dial-decrement)', mode = 'n' },
      { '<C-a>', '<Plug>(dial-increment)', mode = 'v' },
      { '<C-x>', '<Plug>(dial-decrement)', mode = 'v' },
      { 'g<C-a>', 'g<Plug>(dial-increment)', mode = 'v' },
      { 'g<C-x>', 'g<Plug>(dial-decrement)', mode = 'v' },
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
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    dependencies = { 'hrsh7th/nvim-cmp' },
    config = function()
      local autopairs = require('nvim-autopairs')
      if rvim.completion.enable then
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
    cond = rvim.treesitter.enable,
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
      rvim.highlight.plugin('treehopper', {
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
    cond = rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter' },
    -- stylua: ignore
    keys = {
      { '<leader>k', function() require('ts-node-action').node_action() end, desc = 'ts-node-action: run', },
    },
    opts = {},
  },
  {
    'Wansmer/treesj',
    cond = rvim.treesitter.enable,
    keys = {
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'mizlan/iswap.nvim',
    cond = rvim.treesitter.enable,
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'Wansmer/sibling-swap.nvim',
    cond = rvim.treesitter.enable,
    -- stylua: ignore
    keys = {
      { '<leader>ih', function() require('sibling-swap').swap_with_left() end, desc = 'sibling-swap: swap left', },
      { '<leader>il', function() require('sibling-swap').swap_with_right() end, desc = 'sibling-swap: swap right', },
    },
    opts = {
      use_default_keymaps = false,
      highlight_node_at_cursor = true,
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    cond = rvim.treesitter.enable,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    keys = {
      {
        '<leader>r',
        function() require('refactoring').select_refactor() end,
        mode = 'v',
        noremap = true,
        silent = true,
        expr = false,
        desc = 'refactor',
      },
    },
  },
  {
    'nguyenvukhang/nvim-toggler',
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
  {
    'johmsalas/text-case.nvim',
    opts = {},
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    branch = 'use-children',
    cond = rvim.treesitter.enable and rvim.plugins.niceties,
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
    'numToStr/Comment.nvim',
    keys = { 'gcc', { 'gc', mode = { 'x', 'n', 'o' } } },
    opts = function(_, opts)
      local ok, integration =
        pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      if ok then opts.pre_hook = integration.create_pre_hook() end
    end,
  },
  {
    'subnut/nvim-ghost.nvim',
    cond = not rvim.plugins.minimal,
    lazy = not rvim.plugins.overrides.ghost_text.enable,
  },
  {
    's1n7ax/nvim-comment-frame',
    -- stylua: ignore
    keys = {
      { '<localleader>cf', '<Cmd>lua require("nvim-comment-frame").add_comment()<CR>', desc = 'comment-frame: add', },
      { '<localleader>cm', '<Cmd>lua require("nvim-comment-frame").add_multiline_comment()<CR>', desc = 'comment-frame: add multiline', },
    },
    opts = {
      disable_default_keymap = false,
      frame_width = 80,
      fill_char = '-',
      languages = {
        lua = {
          start_str = '--[[',
          end_str = ']]--',
          fill_char = '*',
          frame_width = 80,
          line_wrap_len = 60,
          auto_indent = false,
          add_comment_above = false,
        },
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
  },
  ------------------------------------------------------------------------------
  -- Edit Code Blocks
  ------------------------------------------------------------------------------
  {
    'dawsers/edit-code-block.nvim',
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    opts = { wincmd = 'split' },
  },
  {
    'haolian9/nag.nvim',
    dependencies = { 'haolian9/infra.nvim' },
    -- stylua: ignore
    keys = {
      { mode = 'x', '<localleader>nv', ":lua require'nag'.split('right')<CR>", desc = 'nag: split right', },
      { mode = 'x', '<localleader>ns', ":lua require'nag'.split('below')<CR>", desc = 'nag: split below', },
      { mode = 'x', '<localleader>nt', ":lua require'nag'.tab()<CR>", desc = 'nag: split tab', },
    },
  },
}
