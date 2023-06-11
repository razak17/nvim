return {
  {
    'gbprod/yanky.nvim',
    keys = {
      { 'p', '<Plug>(YankyPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: put after' },
      { 'P', '<Plug>(YankyPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: put before' },
      { 'gp', '<Plug>(YankyGPutAfter)', mode = { 'n', 'x' }, desc = 'yanky: gput after' },
      { 'gP', '<Plug>(YankyGPutBefore)', mode = { 'n', 'x' }, desc = 'yanky: gput before' },
      { '<m-n>', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      { '<m-p>', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      {
        '<localleader>y',
        function() require('telescope').extensions.yank_history.yank_history(rvim.telescope.dropdown()) end,
        desc = 'yanky: open yank history',
      },
    },
    config = function()
      local utils = require('yanky.utils')
      local mapping = require('yanky.telescope.mapping')

      require('yanky').setup({
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
        go = { augend.integer.alias.decimal, augend.integer.alias.hex, operators },
        typescript = { augend.integer.alias.decimal, augend.integer.alias.hex },
        markdown = { augend.integer.alias.decimal, augend.misc.alias.markdown_header },
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
    'mfussenegger/nvim-treehopper',
    enabled = rvim.treesitter.enable,
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
    keys = {
      { '<localleader>lc', function() require('neogen').generate() end, desc = 'neogen: generate doc' },
    },
    opts = { snippet_engine = 'luasnip' },
  },
  {
    'Wansmer/treesj',
    enabled = rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    keys = {
      { 'gS', '<cmd>TSJSplit<CR>', desc = 'split to multiple lines' },
      { 'gJ', '<cmd>TSJJoin<CR>', desc = 'join to single line' },
    },
    opts = { use_default_keymaps = false, max_join_length = 150 },
  },
  {
    'mizlan/iswap.nvim',
    enabled = rvim.treesitter.enable,
    keys = {
      { '<leader>ia', '<cmd>ISwap<CR>', desc = 'iswap: swap' },
      { '<leader>iw', '<cmd>ISwapWith<CR>', desc = 'iswap: swap with' },
    },
  },
  {
    'ThePrimeagen/refactoring.nvim',
    enabled = rvim.treesitter.enable,
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
      { '<leader>ii', '<cmd>lua require("nvim-toggler").toggle()<CR>', desc = 'nvim-toggler: toggle' },
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
      },
    },
  },
  {
    'echasnovski/mini.ai',
    enabled = rvim.treesitter.enable,
    event = 'VeryLazy',
    config = function() require('mini.ai').setup({ mappings = { around_last = '', inside_last = '' } }) end,
  },
  {
    'numToStr/Comment.nvim',
    enabled = rvim.treesitter.enable,
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    keys = { 'gcc', { 'gc', mode = { 'x', 'n', 'o' } } },
    opts = function(_, opts)
      local ok, integration = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
      if ok then opts.pre_hook = integration.create_pre_hook() end
    end,
  },
  {
    'jackMort/ChatGPT.nvim',
    enabled = rvim.ai.enable and not rvim.plugins.minimal,
    cmd = { 'ChatGPT', 'ChatGPTActAs', 'ChatGPTEditWithInstructions' },
    keys = {
      { '<leader>aa', '<cmd>ChatGPTActAs<CR>', desc = 'chatgpt: act as' },
      { '<leader>ae', '<cmd>ChatGPTEditWithInstructions<CR>', desc = 'chatgpt: edit' },
      { '<leader>ag', '<cmd>ChatGPT<CR>', desc = 'chatgpt: open' },
    },
    config = function()
      local border = { style = rvim.ui.border.rectangle, highlight = 'FloatBorder' }
      require('chatgpt').setup({
        popup_window = { border = border },
        popup_input = { border = border, submit = '<C-s>' },
        settings_window = { border = border },
        chat = {
          keymaps = { close = { '<Esc>' } },
        },
      })
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope.nvim',
    },
  },
}
