local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload
local package = require('user.core.plugins').package

-- Debugging
package({
  'rcarriga/nvim-dap-ui',
  config = block_reload(function()
    local dapui = require('dapui')
    require('dapui').setup()
    require('which-key').register({
      ['<localleader>dx'] = { dapui.close, 'dap-ui: close' },
      ['<localleader>do'] = { dapui.toggle, 'dap-ui: toggle' },
    })

    local dap = require('dap')
    -- NOTE: this opens dap UI automatically when dap starts
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
      vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
    end
    dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
    dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
  end),
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
package({
  'neovim/nvim-lspconfig',
  requires = {
    { 'ray-x/go.nvim' },
    { 'nanotee/sqls.nvim' },
    { 'razak17/rust-tools.nvim' },
    { 'antoinemadec/FixCursorHold.nvim' },
    { 'b0o/schemastore.nvim' },
    { 'jose-elias-alvarez/null-ls.nvim', config = conf('lang', 'null-ls') },
    {
      'tamago324/nlsp-settings.nvim',
      config = function()
        require('nlspsettings').setup({
          config_home = join_paths(rvim.get_user_dir(), 'lsp', 'nlsp'),
          -- set to false to overwrite schemastore.nvim
          append_default_schemas = true,
          ignored_servers = {},
          loader = 'json',
        })
      end,
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
          toggle_key = '<C-K>',
          select_signature_key = '<M-N>',
        })
      end,
    },
    {
      'kosayoda/nvim-lightbulb',
      config = function()
        local lightbulb = require('nvim-lightbulb')
        require('zephyr.utils').plugin('Lightbulb', {
          LightBulbFloatWin = { foreground = { from = 'Type' } },
        })
        lightbulb.setup({
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
})

package({
  'williamboman/mason.nvim',
  event = 'BufRead',
  branch = 'main',
  requires = { 'nvim-lspconfig', 'williamboman/mason-lspconfig.nvim' },
  config = function()
    local style = rvim.style
    local icons = style.icons
    local get_config = require('user.core.servers')
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
    require('mason-lspconfig').setup_handlers({
      function(name)
        local config = get_config(name)
        if config then
          if name == 'rust_analyzer' then require('user.lsp.rust') end
          require('lspconfig')[name].setup(config)
        end
      end,
      gopls = require('user.lsp.go'),
    })
  end,
})

-- Treesitter
package({
  'nvim-treesitter/nvim-treesitter',
  run = ':TSUpdate',
  config = conf('lang', 'treesitter'),
  requires = {
    {
      'nvim-treesitter/nvim-treesitter-context',
      config = function()
        local hl = require('zephyr.utils')
        local norm_bg = hl.get('Normal', 'bg')
        local dim = hl.alter_color(norm_bg, 25)
        hl.plugin('treesitter-context', {
          ContextBorder = { foreground = dim },
          TreesitterContext = { inherit = 'Normal' },
          TreesitterContextLineNumber = { inherit = 'LineNr' },
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
      setup = function() rvim.nnoremap('<leader>LE', '<Cmd>TSHighlightCapturesUnderCursor<CR>') end,
    },
    { 'nvim-treesitter/nvim-treesitter-textobjects' },
    { 'p00f/nvim-ts-rainbow' },
    {
      'andymass/vim-matchup',
      after = 'nvim-treesitter',
      config = function()
        require('which-key').register({
          ['<localleader>lm'] = { ':<c-u>MatchupWhereAmI?<CR>', 'matchup: where am i' },
        })
      end,
      disable = true,
    },
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

package({
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  after = 'nvim-cmp',
  config = function()
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

package({
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
    require('zephyr.utils').plugin('copilot', { CopilotSuggestion = { link = 'Comment' } })
  end,
})

package({ 'ii14/emmylua-nvim' })
