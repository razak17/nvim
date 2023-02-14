return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',

  { 'mrshmllow/document-color.nvim', ft = { 'html', 'javascriptreact', 'typescriptreact' } },

  { 'marilari88/twoslash-queries.nvim', ft = { 'typescript', 'typescriptreact' } },

  {
    'neovim/nvim-lspconfig',
    config = function()
      rvim.highlight.plugin('lspconfig', {
        { LspInfoBorder = { link = 'FloatBorder' } },
      })
      require('lspconfig.ui.windows').default_options.border = rvim.style.current.border
    end,
  },

  {
    'joechrisellis/lsp-format-modifications.nvim',
    ft = { 'typescript', 'typescriptreact' },
    keys = {
      {
        '<localleader>lm',
        '<cmd>FormatModifications<CR>',
        desc = 'format-modifications: format',
      },
    },
  },

  {
    'laytan/tailwind-sorter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-lua/plenary.nvim' },
    build = 'cd formatter && npm i && npm run build',
    keys = {
      { '<localleader>lt', '<Cmd>TailwindSort<CR>', desc = 'tailwind-sorter: sort' },
    },
    config = {},
  },

  {
    'SmiteshP/nvim-navic',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      vim.g.navic_silence = true
      local misc = rvim.style.icons.misc
      local lsp_icons = {}
      for key, val in pairs(rvim.style.current.lsp_icons) do
        rvim.highlight.set(
          string.format('NavicIcons%s', key),
          { link = rvim.lsp.kind_highlights[key] }
        )
        lsp_icons[key] = val .. ' '
      end
      require('nvim-navic').setup({
        icons = lsp_icons,
        highlight = true,
        depth_limit_indicator = misc.ellipsis,
        separator = (' %s '):format(misc.arrow_right),
      })
      rvim.highlight.plugin('navic', {
        { NavicText = { bold = false } },
        { NavicSeparator = { link = 'Directory' } },
      })
    end,
  },

  {
    'razak17/glance.nvim',
    keys = {
      { 'gD', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
      { 'gR', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
      { 'gY', '<Cmd>Glance type_definitions<CR>', desc = 'lsp: glance type definitions' },
      { 'gM', '<Cmd>Glance implementations<CR>', desc = 'lsp: glance implementations' },
    },
    config = function()
      require('glance').setup({
        preview_win_opts = { relativenumber = false },
        rvim.highlight.plugin('glance', {
          { GlanceWinBarFilename = { link = 'Error' } },
          { GlanceWinBarFilepath = { link = 'StatusLine' } },
          { GlanceWinBarTitle = { link = 'StatusLine' } },
        }),
      })
    end,
  },

  {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = { accept = '<M-l>', next = '<M-]>', prev = '<M-[>', dismiss = '<C-\\>' },
      },
      filetypes = {
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      },
      server_opts_overrides = {
        settings = {
          advanced = { inlineSuggestCount = 3 },
        },
      },
    },
  },

  {
    'olexsmir/gopher.nvim',
    ft = 'go',
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
  },

  {
    'folke/neodev.nvim',
    opts = {
      debug = true,
      experimental = { pathStrict = true },
      library = {
        runtime = join_paths(vim.env.HOME, 'neovim', 'share', 'nvim', 'runtime'),
        plugins = { 'neotest' },
        types = true,
      },
    },
  },

  {
    'kosayoda/nvim-lightbulb',
    event = 'BufReadPre',
    config = function()
      rvim.highlight.plugin('Lightbulb', {
        { LightBulbFloatWin = { foreground = { from = 'Type' } } },
        { LightBulbVirtualText = { foreground = { from = 'Type' } } },
      })
      local icon = rvim.style.icons.misc.lightbulb
      require('nvim-lightbulb').setup({
        ignore = { 'null-ls' },
        autocmd = { enabled = true },
        sign = { enabled = false },
        virtual_text = { enabled = true, text = icon, hl_mode = 'blend' },
        float = { text = icon, enabled = false, win_opts = { border = 'none' } }, -- 
      })
    end,
  },

  {
    'nvim-treesitter/playground',
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
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
  },

  {
    'lvimuser/lsp-inlayhints.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>lth',
        function() require('lsp-inlayhints').toggle() end,
        desc = 'toggle inlay_hints',
      },
    },
    opts = {
      inlay_hints = {
        highlight = 'Comment',
        labels_separator = ' ⏐ ',
        parameter_hints = {
          prefix = '',
        },
        type_hints = {
          prefix = '=> ',
          remove_colon_start = true,
        },
      },
    },
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
    'andymass/vim-matchup',
    event = 'BufReadPost',
    lazy = false,
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
    keys = {
      {
        '<localleader>lw',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
  },

  {
    'ckolkey/ts-node-action',
    keys = {
      {
        '<localleader>ct',
        function() require('ts-node-action').node_action() end,
        desc = 'ts-node-action: run',
      },
    },
    config = function()
      require('ts-node-action').setup({
        typescriptreact = {
          ['string_fragment'] = require('ts-node-action.actions').conceal_string('…'),
        },
        html = {
          ['attribute_value'] = require('ts-node-action.actions').conceal_string('…'),
        },
      })
    end,
  },
}
