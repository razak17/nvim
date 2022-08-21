local utils = require('user.utils.plugins')
local conf = utils.load_conf
local use = require('user.core.plugins').use

-- Debugging
use({
  'rcarriga/nvim-dap-ui',
  config = function()
    local dapui = require('dapui')
    require('dapui').setup()

    local dap = require('dap')
    -- NOTE: this opens dap UI automatically when dap starts
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
      vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
    end
    dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
  end,
  requires = {
    {
      'mfussenegger/nvim-dap',
      tag = '0.1.*',
      config = conf('lang', 'dap'),
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        require('nvim-dap-virtual-text').setup({
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          all_frames = true,
        })
      end,
    },
  },
})

-- Lsp
use({
  'neovim/nvim-lspconfig',
  module_pattern = 'lspconfig.*',
  requires = {
    { 'ray-x/go.nvim' },
    { 'nanotee/sqls.nvim' },
    { 'christianchiarulli/rust-tools.nvim', branch = 'modularize_and_inlay_rewrite' },
    { 'antoinemadec/FixCursorHold.nvim' },
    { 'b0o/schemastore.nvim' },
    { 'jose-elias-alvarez/null-ls.nvim', config = conf('lang', 'null-ls') },
    {
      'ray-x/lsp_signature.nvim',
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
    },
    {
      'kosayoda/nvim-lightbulb',
      config = function()
        require('user.utils.highlights').plugin('Lightbulb', {
          { LightBulbFloatWin = { foreground = { from = 'Type' } } },
        })
        require('nvim-lightbulb').setup({
          sign = {
            enabled = false,
            -- Priority of the gutter sign
            priority = 10,
          },
          float = { text = '', enabled = true, win_opts = { border = 'none' } }, -- 
          autocmd = { enabled = true },
        })
      end,
    },
  },
  config = function() require('which-key').register({ ['<leader>lh'] = { ':LspInfo<CR>', 'lsp: info' } }) end,
})

use({
  'williamboman/mason.nvim',
  event = 'BufRead',
  requires = { 'nvim-lspconfig', 'williamboman/mason-lspconfig.nvim' },
  config = function()
    local style = rvim.style
    local icons = style.icons
    require('mason').setup({
      install_root_dir = rvim.paths.mason,
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

use({
  'Saecki/crates.nvim',
  ft = 'rust',
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
  requires = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' },
})

-- Treesitter
use({
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = conf('lang', 'treesitter'),
  requires = {
    {
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        local hl = require('user.utils.highlights')
        hl.plugin('treesitter-context', {
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
      setup = function()
        require('which-key').register({
          ['<leader>LE'] = {
            '<Cmd>TSHighlightCapturesUnderCursor<CR>',
            'playground: inspect scope',
          },
        })
      end,
    },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    { 'p00f/nvim-ts-rainbow' },
    {
      'windwp/nvim-ts-autotag',
      config = function()
        require('nvim-ts-autotag').setup({
          filetypes = { 'html', 'xml', 'typescriptreact', 'javascriptreact' },
        })
      end,
    },
    {
      'lewis6991/spellsitter.nvim',
      config = function() require('spellsitter').setup({ enable = true }) end,
    },
  },
})

use({
  'github/copilot.vim',
  config = function()
    vim.g.copilot_no_tab_map = true
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

use({ 'ii14/emmylua-nvim' })

use({
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = { 'BufWinEnter' },
  config = function()
    local lsp_lines = require('lsp_lines')
    lsp_lines.setup()
    lsp_lines.toggle()
  end,
})

use({
  'RRethy/vim-illuminate',
  config = function()
    require('illuminate').configure({
      filetypes_denylist = {
        'alpha',
        'NvimTree',
        'dashboard',
        'neo-tree',
        'qf',
        'lspinfo',
        'lsp-installer',
        'TelescopePrompt',
        'harpoon',
        'packer',
        'mason.nvim',
        'help',
      },
    })
  end,
})

use({
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
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({
  'andymass/vim-matchup',
  after = 'nvim-treesitter',
  config = function()
    require('which-key').register({
      ['<localleader>lm'] = { ':<c-u>MatchupWhereAmI?<CR>', 'matchup: where am i' },
    })
  end,
  disable = true,
})
