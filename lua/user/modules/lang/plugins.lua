return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',
  {
    'folke/neodev.nvim',
    opts = {
      debug = true,
      experimental = { pathStrict = true },
      library = { runtime = join_paths(vim.env.HOME, 'neovim', 'share', 'nvim', 'runtime') },
    },
  },
  { 'mrshmllow/document-color.nvim', ft = { 'html', 'javascriptreact', 'typescriptreact' } },
  { 'marilari88/twoslash-queries.nvim', ft = { 'typescript', 'typescriptreact' } },

  {
    'neovim/nvim-lspconfig',
    config = function()
      require('user.utils.highlights').plugin('lspconfig', {
        { LspInfoBorder = { link = 'FloatBorder' } },
      })
      require('lspconfig.ui.windows').default_options.border = rvim.style.border.current
    end,
  },

  {
    'kosayoda/nvim-lightbulb',
    event = 'BufReadPre',
    config = function()
      require('user.utils.highlights').plugin('Lightbulb', {
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

  -- FIXME: disable for now. hijacks <tab> in insert mode
  {
    'ray-x/lsp_signature.nvim',
    enabled = false,
    event = 'VeryLazy',
    config = function()
      require('lsp_signature').setup({
        debug = false,
        log_path = rvim.get_cache_dir() .. '/lsp_signature.log',
        bind = true,
        fix_pos = false,
        auto_close_after = 15,
        hint_enable = false,
        handler_opts = { border = rvim.style.border.current },
        toggle_key = '<C-I>',
        select_signature_key = '<M-N>',
      })
    end,
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
    'echasnovski/mini.pairs',
    event = 'VeryLazy',
    config = function() require('mini.pairs').setup() end,
  },

  {
    'ckolkey/ts-node-action',
    dependencies = { 'nvim-treesitter' },
    event = 'VeryLazy',
    config = function()
      require('ts-node-action').setup({
        typescriptreact = {
          ['string_fragment'] = require('ts-node-action.actions').conceal_string('…'),
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
