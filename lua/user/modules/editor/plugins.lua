local use = require('user.core.plugins').use
local utils = require('user.utils.plugins')
local conf = utils.load_conf

-- nvim-cmp
use({
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  module = 'cmp',
  config = conf('editor', 'cmp'),
  requires = {
    { 'hrsh7th/cmp-nvim-lsp', module = 'cmp_nvim_lsp' },
    { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
    { 'f3fora/cmp-spell', after = 'nvim-cmp' },
    { 'hrsh7th/cmp-emoji', after = 'nvim-cmp' },
    { 'dmitmel/cmp-cmdline-history', after = 'nvim-cmp' },
    { 'amarakon/nvim-cmp-buffer-lines', after = 'nvim-cmp' },
    { 'lukas-reineke/cmp-rg', tag = '*', after = 'nvim-cmp' },
    { 'rcarriga/cmp-dap', after = 'nvim-cmp' },
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
        -- Refer to install script
        local dicwords = join_paths(rvim.get_runtime_dir(), 'site', 'spell', 'dictionary.txt')
        if vim.fn.filereadable(dicwords) ~= 1 then dicwords = '/usr/share/dict/words' end
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
})

use({
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  module = 'luasnip',
  requires = 'rafamadriz/friendly-snippets',
  config = conf('editor', 'luasnip'),
})

use({
  'xiyaowong/accelerated-jk.nvim',
  event = { 'BufWinEnter' },
  config = function()
    require('accelerated-jk').setup({
      mappings = { j = 'gj', k = 'gk' },
      -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
      -- acceleration_limit = 150,
    })
  end,
})

use({
  'kylechui/nvim-surround',
  event = 'BufRead',
  config = function()
    require('nvim-surround').setup({
      move_cursor = false,
      keymaps = { visual = 'S' },
    })
  end,
})

use({
  'numToStr/Comment.nvim',
  event = 'BufRead',
  config = function()
    require('Comment').setup()
    local ft = require('Comment.ft')
    ft.set('javascriptreact', '{/*%s*/}')
      .set('javascript.jsx', '{/*%s*/}')
      .set('typescriptreact', '{/*%s*/}')
      .set('typescript.tsx', '{/*%s*/}')
      .set('graphql', '//%s')
      .set('json', '//%s')
  end,
})

use({ 'psliwka/vim-dirtytalk', event = 'BufRead', run = ':DirtytalkUpdate' })

use({
  'axelvc/template-string.nvim',
  event = 'BufRead',
  config = function()
    require('template-string').setup({
      remove_template_string = true, -- remove backticks when there are no template string
    })
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({
  'junegunn/vim-easy-align',
  config = function() end,
  disable = true,
})

use({
  'jghauser/fold-cycle.nvim',
  config = function() require('fold-cycle').setup() end,
  disable = true,
})

use({ 'monaqa/dial.nvim', event = 'BufRead', config = conf('editor', 'dial') })

use({
  'Matt-A-Bennett/vim-surround-funk',
  config = function() vim.g.surround_funk_create_mappings = 0 end,
  disable = true,
})

use({
  'chentoast/marks.nvim',
  config = function()
    require('user.utils.highlights').plugin('marks', {
      { MarkSignHL = { link = 'Directory' } },
      { MarkSignNumHL = { link = 'Directory' } },
    })
    require('marks').setup({
      force_write_shada = false, -- This can cause data loss
      excluded_filetypes = { 'NeogitStatus', 'NeogitCommitMessage', 'toggleterm' },
      bookmark_0 = {
        sign = '⚑',
        virt_text = '',
      },
      mappings = {
        annotate = 'm?',
      },
    })
  end,
  disable = true,
})

use({
  'nguyenvukhang/nvim-toggler',
  config = function()
    require('nvim-toggler').setup({
      inverses = {
        ['vim'] = 'emacs',
        ['let'] = 'const',
        ['margin'] = 'padding',
        ['public'] = 'private',
      },
      remove_default_keybinds = true,
    })
  end,
  disable = true,
})
