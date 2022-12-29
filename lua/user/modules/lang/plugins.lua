return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',
  'folke/neodev.nvim',

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
    'razak17/mason.nvim',
    lazy = false,
    init = function() rvim.nnoremap('<leader>lm', '<cmd>Mason<CR>', 'mason: info') end,
    dependencies = { 'williamboman/mason-lspconfig.nvim' },
    config = function()
      local style = rvim.style
      local icons = style.icons
      require('mason').setup({
        ui = {
          border = style.border.current,
          top_offset = 5,
          height = vim.o.lines - vim.o.cmdheight - 5 - 8,
          icons = {
            package_installed = icons.misc.checkmark,
            package_pending = icons.misc.right_arrow,
            package_uninstalled = icons.misc.uninstalled,
          },
        },
      })
      require('mason-lspconfig').setup({
        automatic_installation = rvim.lsp.automatic_servers_installation,
      })
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
    init = function()
      rvim.nnoremap(
        '<leader>Li',
        ':TSHighlightCapturesUnderCursor<CR>',
        'playground: inspect scope'
      )
    end,
    cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = function()
      local cmp_autopairs = require('nvim-autopairs.completion.cmp')
      require('cmp').event:on('confirm_done', cmp_autopairs.on_confirm_done())
      require('nvim-autopairs').setup({
        close_triple_quotes = true,
        check_ts = true,
        fast_wrap = { map = '<c-e>' },
        enable_check_bracket_line = false,
        disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
        ts_config = {
          java = false,
          lua = { 'string', 'source' },
          javascript = { 'string', 'template_string' },
        },
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
    'lvimuser/lsp-inlayhints.nvim',
    event = 'VeryLazy',
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
    event = 'VeryLazy',
    init = function()
      rvim.nnoremap(
        '<localleader>lc',
        function() require('neogen').generate() end,
        'neogen: generate doc'
      )
    end,
    config = function() require('neogen').setup({ snippet_engine = 'luasnip' }) end,
  },

  { 'mrshmllow/document-color.nvim', ft = { 'html', 'javascriptreact', 'typescriptreact' } },

  {
    'ray-x/lsp_signature.nvim',
    event = 'InsertEnter',
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

  { 'marilari88/twoslash-queries.nvim', ft = { 'typescript', 'typescriptreact' } },

  {
    'andymass/vim-matchup',
    event = 'BufReadPre',
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
    init = function() rvim.nnoremap('<leader>lh', ':<c-u>MatchupWhereAmI?<CR>', 'where am i') end,
  },

  ----------------------------------------------------------------------------------------------------
  -- Graveyard
  ----------------------------------------------------------------------------------------------------
  -- {
  --   'RRethy/vim-illuminate',
  --    event = "BufReadPost",
  --   init = function()
  --     rvim.nnoremap(
  --       '<a-n>',
  --       ':lua require"illuminate".next_reference{wrap=true}<CR>',
  --       'illuminate: next'
  --     )
  --     rvim.nnoremap(
  --       '<a-p>',
  --       ':lua require"illuminate".next_reference{reverse=true,wrap=true}<CR>',
  --       'illuminate: reverse'
  --     )
  --   end,
  --   config = function()
  --     require('illuminate').configure({
  --       filetypes_denylist = {
  --         'alpha',
  --         'NvimTree',
  --         'DressingInput',
  --         'dashboard',
  --         'neo-tree',
  --         'neo-tree-popup',
  --         'qf',
  --         'lspinfo',
  --         'lsp-installer',
  --         'TelescopePrompt',
  --         'harpoon',
  --         'packer',
  --         'mason.nvim',
  --         'help',
  --         'CommandTPrompt',
  --         'buffer_manager',
  --         'dapui_scopes',
  --         'dapui_breakpoints',
  --         'dapui_stacks',
  --         'dapui_watches',
  --         'dapui_console',
  --         'dap-repl',
  --       },
  --     })
  --   end,
  -- },
}
