return {
  {
    'razak17/yanky.nvim',
    keys = {
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before' },
      { '<m-n>', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      { '<m-p>', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      {
        '<localleader>y',
        function()
          require('telescope').extensions.yank_history.yank_history(rvim.telescope.dropdown())
        end,
        desc = 'yanky: open yank history',
      },
    },
    config = function()
      local utils = require('yanky.utils')
      local mapping = require('yanky.telescope.mapping')

      -- NOTE: use this workaround until https://github.com/gbprod/yanky.nvim/issues/37 is fixed
      vim.g.clipboard = {
        name = 'xsel_override',
        copy = {
          ['+'] = 'xsel --input --clipboard',
          ['*'] = 'xsel --input --primary',
        },
        paste = {
          ['+'] = 'xsel --output --clipboard',
          ['*'] = 'xsel --output --primary',
        },
        cache_enabled = 1,
      }

      require('yanky').setup({
        dbpath = join_paths(rvim.get_runtime_dir(), 'yanky', 'yanky.db'),
        ring = { storage = 'sqlite' },
        picker = {
          telescope = {
            mappings = {
              default = mapping.put('p'),
              i = {
                ['<c-p>'] = mapping.put('p'),
                ['<c-y>'] = mapping.put('P'),
                ['<c-x>'] = mapping.delete(),
                ['<c-r>'] = mapping.set_register(utils.get_default_register()),
              },
              n = {
                p = mapping.put('p'),
                P = mapping.put('P'),
                d = mapping.delete(),
                r = mapping.set_register(utils.get_default_register()),
              },
            },
          },
        },
      })
    end,
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
        go = { augend.integer.alias.decimal, augend.integer.alias.hex, operators },
        typescript = { augend.integer.alias.decimal, augend.integer.alias.hex },
        markdown = { augend.integer.alias.decimal, augend.misc.alias.markdown_header },
        yaml = { augend.semver.alias.semver },
        toml = { augend.semver.alias.semver },
      })
    end,
  },
  {
    'mfussenegger/nvim-treehopper',
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
          ['zephyr'] = {
            {
              TSNodeKey = {
                fg = { from = 'VertSplit', attr = 'fg', alter = -20 },
                bg = { from = 'qfLineNr', attr = 'fg' },
              },
            },
          },
        },
      })
    end,
  },
  {
    'axelvc/template-string.nvim',
    dependencies = { 'nvim-treesitter' },
    ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
    opts = { remove_template_string = true },
  },
  {
    'danymat/neogen',
    keys = {
      {
        '<localleader>lc',
        function() require('neogen').generate() end,
        desc = 'neogen: generate doc',
      },
    },
    opts = { snippet_engine = 'luasnip' },
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter' },
    keys = {
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  {
    'mizlan/iswap.nvim',
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
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
    keys = {
      {
        '<leader>ii',
        '<cmd>lua require("nvim-toggler").toggle()<CR>',
        desc = 'nvim-toggler: toggle',
      },
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
      },
    },
  },
  {
    'echasnovski/mini.pairs',
    event = 'InsertEnter',
    config = function() require('mini.pairs').setup() end,
  },
  {
    'echasnovski/mini.ai',
    config = function()
      require('mini.ai').setup({ mappings = { around_last = '', inside_last = '' } })
    end,
  },
  {
    'echasnovski/mini.surround',
    keys = { 'ys', 'ds', 'yr' },
    config = function()
      require('mini.surround').setup({
        mappings = {
          add = 'ys', -- Add surrounding in Normal and Visual modes
          delete = 'ds', -- Delete surrounding
          find = 'yf', -- Find surrounding (to the right)
          find_left = 'yF', -- Find surrounding (to the left)
          highlight = 'yh', -- Highlight surrounding
          replace = 'yr', -- Replace surrounding
          update_n_lines = 'yn', -- Update `n_lines`
        },
      })
    end,
  },
  {
    'echasnovski/mini.comment',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    keys = { { 'gc', mode = { 'x', 'n', 'o' } } },
    config = function()
      require('mini.comment').setup({
        hooks = {
          pre = function() require('ts_context_commentstring.internal').update_commentstring() end,
        },
      })
    end,
  },
}
