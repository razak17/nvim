return {
  {
    'kosayoda/nvim-lightbulb',
    cond = ar.lsp.enable,
    event = 'LspAttach',
    opts = {
      autocmd = { enabled = true },
      sign = { enabled = false },
      virtual_text = { enabled = true, hl_mode = 'combine' },
    },
  },
  {
    desc = 'Fully customizable previewer for LSP code actions.',
    'aznhe21/actions-preview.nvim',
    cond = ar.lsp.enable,
    -- stylua: ignore
    keys = { { '<leader>lap', function() require('actions-preview').code_actions() end, desc = 'code action preview' }, },
    opts = {
      backend = { 'snacks', 'telescope', 'minipick', 'nui' },
      telescope = function() ar.telescope.vertical() end,
    },
  },
  {
    'yarospace/dev-tools.nvim',
    cond = ar.lsp.enable and false,
    event = 'LspAttach',
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- code manipulation in buffer, required
      {
        'ThePrimeagen/refactoring.nvim', -- refactoring library, optional
        dependencies = { 'nvim-lua/plenary.nvim' },
      },
    },
    opts = {
      ui = {
        override = true, -- override vim.ui.select, requires `snacks.nvim` to be included in dependencies or installed separately
        group_actions = true, -- group actions by group
        keymaps = {
          filter = '<C-b>',
          open_group = '<C-l>',
          close_group = '<C-h>',
        },
      },
      filetypes = { -- filetypes for which to attach the LSP
        include = {}, -- {} to include all, except for special buftypes, e.g. nofile|help|terminal|prompt
        exclude = {},
      },
    },
  },
}
