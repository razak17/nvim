local conf = require('user.utils.plugins').load_conf

return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',

  -- Debugging
  {
    'mfussenegger/nvim-dap',
    version = '0.1.*',
    init = conf('tools', 'dap').init,
    config = conf('tools', 'dap').config,
  },

  {
    'rcarriga/nvim-dap-ui',
    event = { 'BufRead', 'BufNewFile' },
    init = function()
      rvim.nnoremap(
        '<localleader>dT',
        function() require('dapui').toggle({ reset = true }) end,
        'dapui: toggle'
      )
    end,
    config = function()
      local dapui = require('dapui')
      require('dapui').setup({
        windows = { indent = 2 },
        floating = {
          border = rvim.style.border.current,
        },
      })
      local dap = require('dap')
      -- NOTE: this opens dap UI automatically when dap starts
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
        vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
      end
      dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
      dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
    end,
  },

  {
    'theHamsta/nvim-dap-virtual-text',
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      require('nvim-dap-virtual-text').setup({
        enabled = true,
        enabled_commands = true,
        highlight_changed_variables = true,
        all_frames = true,
      })
    end,
  },

  -- Lsp
  { 'folke/neodev.nvim' },

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
    'jose-elias-alvarez/null-ls.nvim',
    lazy = false,
    dependencies = {
      {
        'jayp0521/mason-null-ls.nvim',
        init = function() rvim.nnoremap('<leader>ln', '<cmd>NullLsInfo<CR>', 'null-ls: info') end,
        config = function()
          require('mason-null-ls').setup({
            automatic_installation = true,
          })
        end,
      },
    },
    config = conf('lang', 'null-ls'),
  },

  {
    'kosayoda/nvim-lightbulb',
    lazy = false,
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

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    init = conf('lang', 'treesitter').init,
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects' },
      { 'p00f/nvim-ts-rainbow' },
      {
        'nvim-treesitter/nvim-treesitter-context',
        event = { 'BufRead', 'BufNewFile' },
        config = function()
          require('user.utils.highlights').plugin('treesitter-context', {
            { ContextBorder = { link = 'Dim' } },
            { TreesitterContext = { inherit = 'Normal' } },
            { TreesitterContextLineNumber = { inherit = 'LineNr' } },
          })
          require('treesitter-context').setup({
            multiline_threshold = 4,
            separator = { '─', 'ContextBorder' }, --[[alernatives: ▁ ─ ▄ ]]
            mode = 'topline',
          })
        end,
      },
      {
        'windwp/nvim-ts-autotag',
        event = 'InsertEnter',
        config = function()
          require('nvim-ts-autotag').setup({
            filetypes = { 'html', 'xml', 'typescriptreact', 'javascriptreact' },
          })
        end,
      },
    },
    config = conf('lang', 'treesitter').config,
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
    'github/copilot.vim',
    event = { 'BufRead', 'BufNewFile' },
    setup = function() vim.g.copilot_no_tab_map = true end,
    config = function()
      rvim.imap('<Plug>(rvim-copilot-accept)', 'copilot#Accept("<Tab>")', { expr = true })
      rvim.inoremap('<M-]>', '<Plug>(copilot-next)')
      rvim.inoremap('<M-[>', '<Plug>(copilot-previous)')
      rvim.inoremap('<C-\\>', '<Cmd>vertical Copilot panel<CR>')

      vim.g.copilot_filetypes = {
        ['*'] = true,
        gitcommit = false,
        NeogitCommitMessage = false,
        DressingInput = false,
        TelescopePrompt = false,
        ['neo-tree-popup'] = false,
        ['dap-repl'] = false,
      }
      require('user.utils.highlights').plugin('copilot', {
        { CopilotSuggestion = { link = 'Comment' } },
      })
    end,
  },

  {
    'lvimuser/lsp-inlayhints.nvim',
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
    lazy = false,
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
    init = function() rvim.nnoremap('<leader>lh', ':<c-u>MatchupWhereAmI?<CR>', 'where am i') end,
  },

  ----------------------------------------------------------------------------------------------------
  -- Graveyard
  ----------------------------------------------------------------------------------------------------
  -- {
  --   'RRethy/vim-illuminate',
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
