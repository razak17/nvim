local conf = require('user.utils').load_conf

local completion = {}

completion['folke/which-key.nvim'] = {
  config = conf('completion', 'which_key'),
}

-- nvim-cmp
completion['hrsh7th/nvim-cmp'] = {
  config = conf('completion', 'cmp'),
}

completion['L3MON4D3/LuaSnip'] = {
  module = 'luasnip',
  requires = 'rafamadriz/friendly-snippets',
  config = conf('completion', 'luasnip'),
}

completion['zbirenbaum/copilot-cmp'] = {
  module = 'copilot_cmp',
}

completion['hrsh7th/cmp-nvim-lsp'] = {}

completion['hrsh7th/cmp-nvim-lua'] = {}

completion['hrsh7th/cmp-nvim-lsp-document-symbol'] = {}

completion['saadparwaiz1/cmp_luasnip'] = {}

completion['hrsh7th/cmp-buffer'] = {}

completion['hrsh7th/cmp-path'] = {}

completion['hrsh7th/cmp-cmdline'] = {}

completion['f3fora/cmp-spell'] = {}

completion['hrsh7th/cmp-emoji'] = {}

completion['octaltree/cmp-look'] = {}

completion['petertriho/cmp-git'] = {
  opt = true,
  config = function()
    require('cmp_git').setup({
      filetypes = { 'gitcommit', 'NeogitCommitMessage' },
    })
  end,
}

completion['David-Kunz/cmp-npm'] = {
  opt = true,
  config = function()
    require('cmp-npm').setup({})
  end,
}

completion['uga-rosa/cmp-dictionary'] = {
  event = 'InsertEnter',
}

completion['dmitmel/cmp-cmdline-history'] = {
  event = 'InsertEnter',
}

completion['github/copilot.vim'] = {
  config = function()
    vim.g.copilot_no_tab_map = true
    rvim.imap('<Plug>(rvim-copilot-accept)', "copilot#Accept('<Tab>')", { expr = true })
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
    require('user.utils.highlights').plugin('copilot', { CopilotSuggestion = { link = 'Comment' } })
  end,
}

completion['zbirenbaum/copilot.lua'] = {
  event = { 'VimEnter' },
  config = function()
    require('copilot').setup({
      cmp = {
        enabled = true,
        method = 'getPanelCompletions',
      },
      panel = { -- no config options yet
        enabled = true,
      },
      ft_disable = {
        'markdown',
        'gitcommit',
        'NeogitCommitMessage',
        'DressingInput',
        'TelescopePrompt',
        'neo-tree-popup',
        'dap-repl',
      },
    })
  end,
}

return completion
