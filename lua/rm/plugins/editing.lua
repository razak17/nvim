return {
  {
    'gbprod/yanky.nvim',
    cmd = { 'YankyRingHistory' },
    keys = {
      {
        'p',
        '<Plug>(YankyPutAfter)',
        mode = { 'n', 'x' },
        desc = 'yanky: put after',
      },
      {
        'P',
        '<Plug>(YankyPutBefore)',
        mode = { 'n', 'x' },
        desc = 'yanky: put before',
      },
      {
        'gp',
        '<Plug>(YankyGPutAfter)',
        mode = { 'n', 'x' },
        desc = 'yanky: gput after',
      },
      {
        'gP',
        '<Plug>(YankyGPutBefore)',
        mode = { 'n', 'x' },
        desc = 'yanky: gput before',
      },
      -- { '<m-n>', '<Plug>(YankyCycleForward)', desc = 'yanky: cycle forward' },
      -- { '<m-p>', '<Plug>(YankyCycleBackward)', desc = 'yanky: cycle backward' },
      {
        '<localleader>y',
        '<Cmd>YankyRingHistory<CR>',
        desc = 'yanky: open yank history',
      },
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
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
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
    'moozd/aidoc.nvim',
    cond = not rvim.plugins.minimal,
    keys = {
      {
        mode = 'x',
        '<leader>do',
        '<cmd>lua require("aidoc.api").generate({width = 65})<CR>',
        desc = 'aidoc: generate',
      },
    },
    opts = {},
  },
  {
    'danymat/neogen',
    keys = {
      {
        '<localleader>nd',
        function() require('neogen').generate() end,
        desc = 'neogen: generate doc',
      },
      {
        '<localleader>nf',
        function() require('neogen').generate({ type = 'file' }) end,
        desc = 'neogen: file doc',
      },
      {
        '<localleader>nc',
        function() require('neogen').generate({ type = 'class' }) end,
        desc = 'neogen: class doc',
      },
      {
        '<localleader>nf',
        function() require('neogen').generate({ type = 'func' }) end,
        desc = 'neogen: func doc',
      },
      {
        '<localleader>nt',
        function() require('neogen').generate({ type = 'type' }) end,
        desc = 'neogen: type doc',
      },
    },
    opts = { snippet_engine = 'luasnip' },
  },
  {
    'ckolkey/ts-node-action',
    cond = rvim.treesitter.enable,
    dependencies = { 'nvim-treesitter' },
    keys = {
      {
        '<leader>k',
        function() require('ts-node-action').node_action() end,
        desc = 'ts-node-action: run',
      },
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
    keys = {
      {
        '<leader>ih',
        function() require('sibling-swap').swap_with_left() end,
        desc = 'sibling-swap: swap left',
      },
      {
        '<leader>il',
        function() require('sibling-swap').swap_with_right() end,
        desc = 'sibling-swap: swap right',
      },
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
        ['pre'] = 'post',
        ['column'] = 'row',
        ['before'] = 'after',
        ['end'] = 'start',
        ['high'] = 'low',
      },
    },
  },
  {
    'johmsalas/text-case.nvim',
    opts = {},
  },
  {
    'HiPhish/rainbow-delimiters.nvim',
    branch = 'use-children',
    cond = rvim.treesitter.enable,
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
    'robitx/gp.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    keys = {
      -- Chat commands
      {
        '<c-g>n',
        '<Cmd>GpChatNew<CR>',
        desc = 'gp: new chat',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>f',
        '<Cmd>GpChatFinder<CR>',
        desc = 'gp: find chat',
        mode = { 'n', 'i' },
      },
      {
        '<c-g><c-g>',
        '<Cmd>GpChatRespond<CR>',
        desc = 'gp: respond',
        mode = { 'n', 'i' },
      },
      {
        '<c-g>d',
        '<Cmd>GpChatDeleteCR>',
        desc = 'gp: delete chat',
        mode = { 'n', 'i' },
      },
      -- Prompt commands
      {
        '<c-g>i',
        '<Cmd>GpInline<CR>',
        desc = 'gp: inline',
        mode = { 'n', 'i' },
      },
      {
        '<c-g>r',
        '<Cmd>GpRewrite<CR>',
        desc = 'gp: rewrite',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>a',
        '<Cmd>GpAppend<CR>',
        desc = 'gp: append',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>b',
        '<Cmd>GpPrepend<CR>',
        desc = 'gp: prepend',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>e',
        '<Cmd>GpEnew<CR>',
        desc = 'gp: enew',
        mode = { 'n', 'i', 'v' },
      },
      {
        '<c-g>p',
        '<Cmd>GpPopup<CR>',
        desc = 'gp: popup',
        mode = { 'n', 'i', 'v' },
      },
    },
    opts = {},
  },
  {
    'jackMort/ChatGPT.nvim',
    cond = rvim.ai.enable and not rvim.plugins.minimal,
    cmd = { 'ChatGPT', 'ChatGPTActAs', 'ChatGPTEditWithInstructions' },
    keys = {
      { '<leader>aa', '<cmd>ChatGPTActAs<CR>', desc = 'chatgpt: act as' },
      {
        '<leader>ae',
        '<cmd>ChatGPTEditWithInstructions<CR>',
        desc = 'chatgpt: edit',
      },
      { '<leader>an', '<cmd>ChatGPT<CR>', desc = 'chatgpt: open' },
    },
    config = function()
      local border =
        { style = rvim.ui.border.rectangle, highlight = 'FloatBorder' }
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
  {
    'piersolenski/wtf.nvim',
    cond = rvim.lsp.enable,
    event = 'VeryLazy',
    opts = {},
    keys = {
      {
        '<leader>ao',
        function() require('wtf').ai() end,
        desc = 'wtf: debug diagnostic with AI',
      },
      {
        '<leader>ag',
        function() require('wtf').search() end,
        desc = 'wtf: google search diagnostic',
      },
    },
    dependencies = { 'MunifTanjim/nui.nvim' },
  },
  {
    'subnut/nvim-ghost.nvim',
    cond = not rvim.plugins.minimal,
    lazy = not rvim.plugins.overrides.ghost_text.enable,
  },
  {
    'ecthelionvi/NeoComposer.nvim',
    cond = not rvim.plugins.minimal,
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'kkharji/sqlite.lua' },
    keys = {
      {
        '<localleader>qe',
        "<cmd>lua require('NeoComposer.ui').edit_macros()<cr>",
        desc = 'neocomposer: edit macro ',
      },
      {
        '<localleader>qt',
        "<cmd>lua require('NeoComposer.macro').toggle_delay()<cr>",
        desc = 'neocomposer: delay macro toggle',
      },
      {
        '<localleader>qd',
        "<cmd>lua require('NeoComposer.store').clear_macros()<cr>",
        desc = 'neocomposer: delete all macros',
      },
    },
    config = function()
      require('NeoComposer').setup({
        notify = false,
        keymaps = {
          toggle_record = '<localleader>qr',
          play_macro = '<localleader>qq',
          yank_macro = '<localleader>qy',
          stop_macro = '<localleader>qs',
          cycle_next = '<localleader>qn',
          cycle_prev = '<localleader>qp',
          toggle_macro_menu = '<localleader>qm',
        },
      })
      if rvim.is_available('which-key.nvim') then
        require('which-key').register({
          ['<localleader>qr'] = 'neocomposer: toggle record',
          ['<localleader>qq'] = 'neocomposer: play macro',
          ['<localleader>qy'] = 'neocomposer: yank macro',
          ['<localleader>qs'] = 'neocomposer: stop macro',
          ['<localleader>qn'] = 'neocomposer: cycle next',
          ['<localleader>qp'] = 'neocomposer: cycle prev',
          ['<localleader>qm'] = 'neocomposer: toggle menu',
        })
        require('which-key').register({
          qq = 'neocomposer: play macro',
        }, { mode = 'x', prefix = '<localleader>' })
      end
    end,
  },
  {
    'ej-shafran/compile-mode.nvim',
    cmd = { 'Compile', 'Recompile' },
    opts = {
      default_command = '',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'm00qek/baleia.nvim', tag = 'v1.3.0' },
    },
  },
  {
    'dawsers/edit-code-block.nvim',
    cmd = { 'EditCodeBlock', 'EditCodeBlockOrg', 'EditCodeBlockSelection' },
    name = 'ecb',
    opts = { wincmd = 'split' },
  },
  {
    'haolian9/nag.nvim',
    dependencies = { 'haolian9/infra.nvim' },
    keys = {
      {
        mode = 'x',
        '<localleader>nv',
        ":lua require'nag'.split('right')<CR>",
        desc = 'nag: split right',
      },
      {
        mode = 'x',
        '<localleader>ns',
        ":lua require'nag'.split('below')<CR>",
        desc = 'nag: split below',
      },
      {
        mode = 'x',
        '<localleader>nt',
        ":lua require'nag'.tab()<CR>",
        desc = 'nag: split tab',
      },
    },
  },
}
