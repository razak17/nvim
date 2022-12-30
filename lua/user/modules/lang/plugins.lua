return {
  'nanotee/sqls.nvim',
  'b0o/schemastore.nvim',
  'simrat39/rust-tools.nvim',
  'jose-elias-alvarez/typescript.nvim',
  'folke/neodev.nvim',
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

  {
    'andymass/vim-matchup',
    event = 'BufReadPre',
    config = function() vim.g.matchup_matchparen_enabled = 0 end,
    init = function() rvim.nnoremap('<leader>lh', ':<c-u>MatchupWhereAmI?<CR>', 'where am i') end,
  },
}
