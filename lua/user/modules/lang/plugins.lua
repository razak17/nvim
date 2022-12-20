local use = require('user.core.packer').use
local conf = require('user.utils.plugins').load_conf

-- Lsp
use({
  'neovim/nvim-lspconfig',
  module_pattern = 'lspconfig.*',
  config = function()
    require('user.utils.highlights').plugin('lspconfig', {
      { LspInfoBorder = { link = 'FloatBorder' } },
    })
    require('lspconfig.ui.windows').default_options.border = rvim.style.border.current
  end,
  requires = {
    { 'nanotee/sqls.nvim' },
    { 'simrat39/rust-tools.nvim', branch = 'modularize_and_inlay_rewrite' },
    { 'b0o/schemastore.nvim' },
  },
})

use({
  'razak17/mason.nvim',
  local_path = 'personal',
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
})

use({ 'williamboman/mason-lspconfig.nvim' })

use({ 'jose-elias-alvarez/null-ls.nvim', config = conf('lang', 'null-ls') })

use({
  'jayp0521/mason-null-ls.nvim',
  after = 'local-mason.nvim',
  config = function()
    require('mason-null-ls').setup({
      automatic_installation = true,
    })
  end,
})

use({
  'kosayoda/nvim-lightbulb',
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
})

-- Treesitter
use({
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = conf('lang', 'treesitter'),
  requires = {
    {
      'nvim-treesitter/nvim-treesitter-context',
      event = 'BufRead',
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
    -- use this until:  https://github.com/nvim-treesitter/playground/pull/57 is merged
    { 'nullchilly/lsp-playground' },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    { 'p00f/nvim-ts-rainbow' },
    {
      'windwp/nvim-ts-autotag',
      event = 'BufRead',
      config = function()
        require('nvim-ts-autotag').setup({
          filetypes = { 'html', 'xml', 'typescriptreact', 'javascriptreact' },
        })
      end,
    },
  },
})

use({
  'windwp/nvim-autopairs',
  after = 'nvim-cmp',
  requires = 'nvim-cmp',
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
})

use({
  'github/copilot.vim',
  after = 'nvim-cmp',
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
})

use({
  'RRethy/vim-illuminate',
  event = 'BufRead',
  config = function()
    require('illuminate').configure({
      filetypes_denylist = {
        'alpha',
        'NvimTree',
        'DressingInput',
        'dashboard',
        'neo-tree',
        'neo-tree-popup',
        'qf',
        'lspinfo',
        'lsp-installer',
        'TelescopePrompt',
        'harpoon',
        'packer',
        'mason.nvim',
        'help',
        'CommandTPrompt',
        'buffer_manager',
      },
    })
  end,
})

use({
  'lvimuser/lsp-inlayhints.nvim',
  event = { 'BufRead', 'BufNewFile' },
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
})

use({
  'danymat/neogen',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function() require('neogen').setup({ snippet_engine = 'luasnip' }) end,
})

use({ 'mrshmllow/document-color.nvim', ft = { 'html', 'javascriptreact', 'typescriptreact' } })

use({ 'ii14/emmylua-nvim' })

use({
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
})

use({ 'jose-elias-alvarez/typescript.nvim' })

use({ 'marilari88/twoslash-queries.nvim', ft = { 'typescript', 'typescriptreact' } })

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({
  'andymass/vim-matchup',
  after = 'nvim-treesitter',
  config = function() rvim.nnoremap('<leader>lm', ':<c-u>MatchupWhereAmI?<CR>', 'where am i') end,
  disable = true,
})
