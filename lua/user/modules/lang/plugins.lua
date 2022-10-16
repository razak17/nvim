local utils = require('user.utils.plugins')
local conf = utils.load_conf
local use = require('user.core.packer').use

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
  'williamboman/mason.nvim',
  event = 'BufRead',
  requires = { 'nvim-lspconfig', 'williamboman/mason-lspconfig.nvim' },
  config = function()
    local style = rvim.style
    local icons = style.icons
    require('mason').setup({
      install_root_dir = rvim.path.mason,
      ui = {
        border = style.border.current,
        icons = {
          package_installed = icons.misc.checkmark,
          package_pending = icons.misc.right_arrow,
          package_uninstalled = icons.misc.x,
        },
      },
    })
    require('mason-lspconfig').setup({
      automatic_installation = rvim.lsp.automatic_servers_installation,
    })
  end,
})

use({ 'jose-elias-alvarez/null-ls.nvim', config = conf('lang', 'null-ls') })

use({
  'jayp0521/mason-null-ls.nvim',
  requires = {
    'williamboman/mason.nvim',
    'jose-elias-alvarez/null-ls.nvim',
  },
  after = 'mason.nvim',
  config = function()
    require('mason-null-ls').setup({
      automatic_installation = true,
    })
  end,
})

use({
  'kosayoda/nvim-lightbulb',
  event = 'BufRead',
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
    {
      'nvim-treesitter/playground',
      cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
    },
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
      },
    })
  end,
})

use({
  'lvimuser/lsp-inlayhints.nvim',
  event = 'BufRead',
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

use({ 'mrshmllow/document-color.nvim' })

use({ 'ii14/emmylua-nvim' })

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({
  'andymass/vim-matchup',
  after = 'nvim-treesitter',
  config = function() rvim.nnoremap('<leader>lm', ':<c-u>MatchupWhereAmI?<CR>', 'where am i') end,
  disable = true,
})

use({
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = { 'BufWinEnter' },
  disable = true,
  config = function()
    local lsp_lines = require('lsp_lines')
    lsp_lines.setup()
    lsp_lines.toggle()
  end,
})

use({
  'Saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  requires = { 'nvim-lua/plenary.nvim' },
  disable = true,
  config = function()
    require('crates').setup({
      popup = {
        -- autofocus = true,
        style = 'minimal',
        border = 'rounded',
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
      },
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
    })
  end,
})

use({
  'olexsmir/gopher.nvim',
  disable = true,
  requires = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
})

use({
  'mfussenegger/nvim-treehopper',
  disable = true,
  config = function()
    rvim.augroup('TreehopperMaps', {
      {
        event = 'FileType',
        command = function(args)
          -- FIXME: this issue should be handled inside the plugin rather than manually
          local langs = require('nvim-treesitter.parsers').available_parsers()
          if vim.tbl_contains(langs, vim.bo[args.buf].filetype) then
            rvim.omap('u', ":<c-u>lua require('tsht').nodes()<cr>", { buffer = args.buf })
            rvim.vnoremap('u', ":lua require('tsht').nodes()<CR>", { buffer = args.buf })
          end
        end,
      },
    })
  end,
})

use({
  'ray-x/lsp_signature.nvim',
  disable = true,
  config = function()
    require('lsp_signature').setup({
      debug = false,
      log_path = rvim.get_cache_dir() .. '/lsp_signature.log',
      bind = true,
      fix_pos = false,
      auto_close_after = 15,
      hint_enable = false,
      handler_opts = { border = rvim.style.border.current },
      toggle_key = '<C-K>',
      select_signature_key = '<M-N>',
    })
  end,
})
