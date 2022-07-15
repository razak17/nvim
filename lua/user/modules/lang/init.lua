local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload

local lang = {}

-- Debugging
lang['rcarriga/nvim-dap-ui'] = {
  requires = {
    {
      'mfussenegger/nvim-dap',
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
  config = block_reload(conf('lang', 'dap-ui')),
}

-- Lsp
lang['neovim/nvim-lspconfig'] = {
  requires = {
    { 'antoinemadec/FixCursorHold.nvim' },
    { 'nanotee/sqls.nvim' },
    { 'b0o/schemastore.nvim' },
    { 'razak17/rust-tools.nvim' },
    {
      'jose-elias-alvarez/null-ls.nvim',
      config = function()
        rvim.augroup('NullLsConfig', {
          {
            event = 'Filetype',
            pattern = 'null-ls-info',
            command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
          },
        })
      end,
    },
    {
      'tamago324/nlsp-settings.nvim',
      config = function()
        require('nvim-lsp-installer').setup({
          config_home = join_paths(rvim.get_user_dir(), 'lsp', 'lsp-settings'),
          -- set to false to overwrite schemastore.nvim
          append_default_schemas = true,
          ignored_servers = {},
          loader = 'json',
        })
      end,
    },
    {
      'williamboman/mason.nvim',
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
          ensure_installed = rvim.lsp.configured_servers,
        })
      end,
    },
    {
      'williamboman/nvim-lsp-installer',
      config = function()
        local icons = rvim.style.icons
        require('nvim-lsp-installer').setup({
          ensure_installed = {},
          install_root_dir = join_paths(rvim.get_runtime_dir(), 'lsp_servers'),
          ui = {
            icons = {
              server_installed = icons.misc.checkmark,
              server_pending = icons.misc.right_arrow,
              server_uninstalled = icons.misc.x,
            },
          },
        })
        rvim.augroup('LspInstallerConfig', {
          {
            event = 'Filetype',
            pattern = 'lsp-installer',
            command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
          },
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
    {
      'simrat39/symbols-outline.nvim',
      config = conf('lang', 'symbols-outline'),
    },
  },
}

lang['olexsmir/gopher.nvim'] = {
  ft = 'go',
  requires = { -- dependencies
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
}
-- Treesitter
lang['nvim-treesitter/nvim-treesitter'] = {
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
      event = 'VimEnter',
      keys = '<leader>LE',
      module = 'nvim-treesitter-playground',
      cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
      setup = function() require('which-key').register({ ['<leader>LE'] = 'treesitter: inspect token' }) end,
      config = function() rvim.nnoremap('<leader>LE', '<Cmd>TSHighlightCapturesUnderCursor<CR>') end,
    },
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      after = 'nvim-treesitter',
    },
    {
      'p00f/nvim-ts-rainbow',
      after = 'nvim-treesitter',
    },
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
      config = function()
        require('spellsitter').setup({
          enable = true,
        })
      end,
    },
  },
}

lang['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  after = { 'telescope.nvim', 'nvim-treesitter' },
  config = conf('lang', 'autopairs'),
}

-- nvim-cmp
lang['hrsh7th/nvim-cmp'] = {
  module = 'cmp',
  event = 'InsertEnter',
  config = conf('lang', 'cmp'),
  requires = {
    { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
    { 'f3fora/cmp-spell', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
    { 'octaltree/cmp-look', after = 'nvim-cmp' },
    { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
    {
      'David-Kunz/cmp-npm',
      after = 'nvim-cmp',
      config = function() require('cmp-npm').setup({}) end,
    },
    {
      'petertriho/cmp-git',
      after = 'nvim-cmp',
      config = function()
        require('cmp_git').setup({
          filetypes = { 'gitcommit', 'NeogitCommitMessage' },
        })
      end,
    },
    {
      'uga-rosa/cmp-dictionary',
      after = 'nvim-cmp',
      config = function()
        -- Check install script
        local dicwords = join_paths(rvim.get_runtime_dir(), 'site', 'dictionary.txt')

        if vim.fn.filereadable(dicwords) ~= 1 then
          dicwords = '/usr/share/dict/words'
        end
        require('cmp_dictionary').setup({
          async = true,
          dic = {
            ['*'] = dicwords,
          },
        })
        require('cmp_dictionary').update()
      end,
    },
  },
}

lang['L3MON4D3/LuaSnip'] = {
  event = 'InsertEnter',
  module = 'luasnip',
  requires = 'rafamadriz/friendly-snippets',
  config = conf('lang', 'luasnip'),
}

lang['github/copilot.vim'] = {
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
}

return lang
