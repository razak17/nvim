local hl = require('user.utils.highlights')

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
      hl.plugin('lspconfig', {
        { LspInfoBorder = { link = 'FloatBorder' } },
      })
      require('lspconfig.ui.windows').default_options.border = rvim.style.current.border
    end,
  },

  {
    'DNLHC/glance.nvim',
    keys = {
      { 'gD', '<Cmd>Glance definitions<CR>', desc = 'lsp: glance definitions' },
      { 'gR', '<Cmd>Glance references<CR>', desc = 'lsp: glance references' },
      { 'gY', '<Cmd>Glance type_definitions<CR>', desc = 'lsp: glance type definitions' },
      { 'gM', '<Cmd>Glance implementations<CR>', desc = 'lsp: glance implementations' },
    },
    config = function()
      require('glance').setup({
        hl.plugin('glance', {
          { GlancePreviewNormal = { link = 'Normal' } },
          { GlanceListCount = { link = 'Normal' } },
        }),
      })
    end,
  },

  {
    'zbirenbaum/copilot.lua',
    event = 'VeryLazy',
    config = function()
      require('copilot').setup({
        suggestion = { auto_trigger = true },
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
      })
    end,
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
      hl.plugin('Lightbulb', {
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
    'lvimuser/lsp-inlayhints.nvim',
    event = 'VeryLazy',
    keys = {
      {
        '<leader>lth',
        function() require('lsp-inlayhints').toggle() end,
        desc = 'toggle inlay_hints',
      },
    },
    config = function()
      require('lsp-inlayhints').setup({
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
      })
    end,
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
        '<localleader>lm',
        ':<c-u>MatchupWhereAmI?<CR>',
        desc = 'matchup: where am i',
      },
    },
  },

  {
    'ckolkey/ts-node-action',
    dependencies = { 'nvim-treesitter' },
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
    keys = {
      {
        '<localleader>ct',
        function() require('ts-node-action').node_action() end,
        desc = 'ts-node-action: run',
      },
    },
  },

  {
    'joechrisellis/lsp-format-modifications.nvim',
    config = function()
      rvim.nnoremap(
        '<localleader>lf',
        '<cmd>FormatModifications<CR>',
        'lsp-format-modifications: format'
      )
    end,
    ft = { 'typescript', 'typescriptreact' },
  },

  {
    'folke/paint.nvim',
    enabled = false,
    event = 'BufReadPre',
    config = function()
      require('paint').setup({
        highlights = {
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%-%s*(@%w+)',
            hl = 'Constant',
          },
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%[%[(@%w+)',
            hl = 'Constant',
          },
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%-%s*@field%s+(%S+)',
            hl = '@field',
          },
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%-%s*@class%s+(%S+)',
            hl = '@variable.builtin',
          },
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%-%s*@alias%s+(%S+)',
            hl = '@keyword',
          },
          {
            filter = { filetype = 'lua' },
            pattern = '%s*%-%-%-%s*@param%s+(%S+)',
            hl = '@parameter',
          },
        },
      })
    end,
  },
}
