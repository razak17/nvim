local hl = rvim.highlight
local ui = rvim.ui

return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',
  'mrshmllow/document-color.nvim',
  'marilari88/twoslash-queries.nvim',

  {
    'neovim/nvim-lspconfig',
    config = function()
      hl.plugin('lspconfig', {
        { LspInfoBorder = { link = 'FloatBorder' } },
      })
      require('lspconfig.ui.windows').default_options.border = ui.current.border
    end,
  },

  {
    'ray-x/lsp_signature.nvim',
    event = 'InsertEnter',
    opts = {
      bind = true,
      fix_pos = false,
      auto_close_after = 15, -- close after 15 seconds
      hint_enable = false,
      handler_opts = { border = ui.current.border },
      toggle_key = '<C-K>',
      select_signature_key = '<M-N>',
    },
  },

  {
    'joechrisellis/lsp-format-modifications.nvim',
    keys = {
      { '<localleader>lm', '<cmd>FormatModifications<CR>', desc = 'format-modifications: format' },
    },
  },

  {
    'laytan/tailwind-sorter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-lua/plenary.nvim' },
    build = 'cd formatter && npm i && npm run build',
    keys = { { '<localleader>lt', '<Cmd>TailwindSort<CR>', desc = 'tailwind-sorter: sort' } },
    opts = {},
  },

  {
    'SmiteshP/nvim-navic',
    event = { 'BufRead', 'BufNewFile' },
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      vim.g.navic_silence = true
      local fmt = string.format
      local misc = ui.icons.misc
      local lsp_icons = {}
      for key, val in pairs(ui.current.lsp_icons) do
        hl.set(fmt('NavicIcons%s', key), { link = rvim.lsp.kind_highlights[key] })
        lsp_icons[key] = val .. ' '
      end
      require('nvim-navic').setup({
        icons = lsp_icons,
        highlight = true,
        depth_limit_indicator = misc.ellipsis,
        separator = fmt(' %s ', misc.arrow_right),
      })
      hl.plugin('navic', {
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
        hl.plugin('glance', {
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
        keymap = {
          accept_word = '<M-w>',
          accept_line = '<M-l>',
          accept = '<M-u>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-\\>',
        },
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
    event = 'LspAttach',
    config = function()
      hl.plugin('Lightbulb', {
        { LightBulbFloatWin = { foreground = { from = 'Type' } } },
        { LightBulbVirtualText = { foreground = { from = 'Type' } } },
      })
      local icon = ui.icons.misc.lightbulb
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
    event = 'LspAttach',
    keys = {
      {
        '<leader>lth',
        function() require('lsp-inlayhints').toggle() end,
        desc = 'toggle inlay hints',
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
    keys = { { '<localleader>lw', ':<c-u>MatchupWhereAmI?<CR>', desc = 'matchup: where am i' } },
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
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

  {
    'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
    event = 'LspAttach',
    config = function() require('lsp_lines').setup() end,
  },
}
