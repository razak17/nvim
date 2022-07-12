local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload

local lang = {}

-- Debugging
lang['mfussenegger/nvim-dap'] = {
  config = conf('lang', 'dap'),
  requires = {
    {
      'rcarriga/nvim-dap-ui',
      after = 'nvim-dap',
      config = block_reload(conf('lang', 'dap-ui')),
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      after = 'nvim-dap',
      config = function()
        require('nvim-dap-virtual-text').setup({
          enabled = true, -- enable this plugin (the default)
          enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
          highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
          all_frames = true, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        })
      end,
    },
  },
}

lang['ravenxrz/DAPInstall.nvim'] = {
  config = require('dap-install').setup({
    installation_path = rvim.paths.dap_install_dir,
  }),
}

lang['jbyuki/one-small-step-for-vimkind'] = {
  requires = 'nvim-dap',
  config = function()
    local nnoremap = rvim.nnoremap
    nnoremap('<Leader>dE', ':lua require"osv".run_this()<CR>')
    nnoremap('<Leader>dl', ':lua require"osv".launch()<CR>')

    require('which-key').register({
      ['<leader>dE'] = 'osv run this',
      ['<leader>dL'] = 'osv launch',
    })
  end,
  disable = true,
}

-- Lsp
lang['williamboman/mason.nvim'] = {
  config = function()
    require('mason').setup({
      ui = { border = rvim.style.border.current },
      -- The directory in which to install packages.
      install_root_dir = join_paths(rvim.get_runtime_dir(), 'mason'),
    })
    require('mason-lspconfig').setup({
      automatic_installation = true,
    })
  end,
}

lang['williamboman/nvim-lsp-installer'] = {
  requires = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    rvim.augroup('LspInstallerConfig', {
      {
        event = 'Filetype',
        pattern = 'lsp-installer',
        command = function()
          vim.api.nvim_win_set_config(0, { border = rvim.style.border.current })
        end,
      },
    })
  end,
}

lang['antoinemadec/FixCursorHold.nvim'] = {}

lang['neovim/nvim-lspconfig'] = {}

lang['tamago324/nlsp-settings.nvim'] = {}

lang['jose-elias-alvarez/null-ls.nvim'] = {}

lang['kosayoda/nvim-lightbulb'] = {
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
}

lang['simrat39/symbols-outline.nvim'] = {
  config = conf('lang', 'symbols-outline'),
}

lang['ray-x/lsp_signature.nvim'] = {
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
}

lang['olexsmir/gopher.nvim'] = {
  ft = 'go',
  requires = { -- dependencies
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
}

lang['nanotee/sqls.nvim'] = {}

lang['razak17/rust-tools.nvim'] = {}

-- Treesitter
lang['nvim-treesitter/nvim-treesitter'] = {
  run = ':TSUpdate',
  config = conf('lang', 'treesitter'),
}

lang['nvim-treesitter/nvim-treesitter-context'] = {
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
}

lang['nvim-treesitter/playground'] = {
  event = 'VimEnter',
  keys = '<leader>LE',
  module = 'nvim-treesitter-playground',
  cmd = { 'TSPlaygroundToggle', 'TSHighlightCapturesUnderCursor' },
  setup = function()
    require('which-key').register({ ['<leader>LE'] = 'treesitter: inspect token' })
  end,
  config = function()
    rvim.nnoremap('<leader>LE', '<Cmd>TSHighlightCapturesUnderCursor<CR>')
  end,
}

lang['nvim-treesitter/nvim-treesitter-textobjects'] = {
  after = 'nvim-treesitter',
}

lang['p00f/nvim-ts-rainbow'] = {
  after = 'nvim-treesitter',
}

lang['andymass/vim-matchup'] = {
  after = 'nvim-treesitter',
  config = function()
    require('which-key').register({
      ['<localleader>lm'] = { ':<c-u>MatchupWhereAmI?<CR>', 'matchup: where am i' },
    })
  end,
}

lang['windwp/nvim-ts-autotag'] = {
  config = function()
    require('nvim-ts-autotag').setup({
      filetypes = { 'html', 'xml', 'typescriptreact', 'javascriptreact' },
    })
  end,
}

lang['windwp/nvim-autopairs'] = {
  event = 'InsertEnter',
  after = { 'telescope.nvim', 'nvim-treesitter' },
  config = conf('lang', 'autopairs'),
}

lang['lewis6991/spellsitter.nvim'] = {
  config = function()
    require('spellsitter').setup({
      enable = true,
    })
  end,
}

-- nvim-cmp
lang['hrsh7th/nvim-cmp'] = {
  module = 'cmp',
  event = 'InsertEnter',
  config = conf('lang', 'cmp'),
}
lang['hrsh7th/cmp-nvim-lsp'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-nvim-lua'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-nvim-lsp-document-symbol'] = { after = 'nvim-cmp' }
lang['saadparwaiz1/cmp_luasnip'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-buffer'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-path'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-cmdline'] = { after = 'nvim-cmp' }
lang['f3fora/cmp-spell'] = { after = 'nvim-cmp' }
lang['hrsh7th/cmp-emoji'] = { after = 'nvim-cmp' }
lang['octaltree/cmp-look'] = { after = 'nvim-cmp' }
lang['petertriho/cmp-git'] = {
  after = 'nvim-cmp',
  config = function()
    require('cmp_git').setup({
      filetypes = { 'gitcommit', 'NeogitCommitMessage' },
    })
  end,
}
lang['David-Kunz/cmp-npm'] = {
  after = 'nvim-cmp',
  config = function()
    require('cmp-npm').setup({})
  end,
}
lang['uga-rosa/cmp-dictionary'] = {
  after = 'nvim-cmp',
  config = function()
    require('cmp_dictionary').setup({
      async = true,
      dic = {
        ['*'] = { '/usr/share/dict/words' },
      },
    })
    require('cmp_dictionary').update()
  end,
}
lang['dmitmel/cmp-cmdline-history'] = {
  after = 'nvim-cmp',
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

-- Rest
lang['b0o/schemastore.nvim'] = {}

return lang
