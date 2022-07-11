local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload

local lang = {}

-- Debugging
lang['mfussenegger/nvim-dap'] = {
  config = conf('lang', 'dap').config,
  setup = conf('lang', 'dap').setup,
}

lang['rcarriga/nvim-dap-ui'] = {
  config = block_reload(conf('lang', 'dap-ui')),
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

lang['theHamsta/nvim-dap-virtual-text'] = {
  after = 'nvim-dap',
  config = function()
    require('nvim-dap-virtual-text').setup({
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      all_frames = true, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
    })
  end,
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

-- Rest
lang['b0o/schemastore.nvim'] = {}

lang['mtdl9/vim-log-highlighting'] = {}

lang['fladson/vim-kitty'] = {}

lang['pantharshit00/vim-prisma'] = {}

return lang
