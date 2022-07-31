local package = require('user.core.plugins').package
local utils = require('user.utils.plugins')
local conf = utils.load_conf

-- nvim-cmp
package({
  'hrsh7th/nvim-cmp',
	event = "InsertEnter",
	module = "cmp",
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

package({
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  module = 'luasnip',
  requires = 'rafamadriz/friendly-snippets',
  config = conf('editor', 'luasnip'),
})

package({
  'xiyaowong/accelerated-jk.nvim',
  event = { 'BufWinEnter' },
  config = function()
    if not rvim.plugin_installed('accelerated-jk.nvim') then return end
    require('accelerated-jk').setup({
      mappings = { j = 'gj', k = 'gk' },
      -- If the interval of key-repeat takes more than `acceleration_limit` ms, the step is reset
      -- acceleration_limit = 150,
    })
  end,
})

package({
  'kylechui/nvim-surround',
  config = function()
    if not rvim.plugin_installed('nvim-surround') then return end
    require('nvim-surround').setup()
  end,
})

package({ 'monaqa/dial.nvim', config = conf('editor', 'dial') })

package({
  'norcalli/nvim-colorizer.lua',
  config = function()
    if not rvim.plugin_installed('nvim-colorizer.lua') then return end
    require('colorizer').setup({ 'lua', 'css', 'vim', 'kitty', 'conf' }, {
      css = { rgb_fn = true, hsl_fn = true, names = true },
      scss = { rgb_fn = true, hsl_fn = true, names = true },
      sass = { rgb_fn = true, names = true },
      vim = { names = true },
      html = { mode = 'foreground' },
    }, {
      RGB = false,
      names = false,
      mode = 'background',
    })
  end,
})

package({
  'romainl/vim-cool',
  config = function()
    if not rvim.plugin_installed('vim-cool') then return end
    vim.g.CoolTotalMatches = 1
  end,
})

package({
  'numToStr/Comment.nvim',
  config = function()
    if not rvim.plugin_installed('Comment.nvim') then return end
    require('Comment').setup()
    local ft = require('Comment.ft')
    ft
      .set('javascriptreact', '{/*%s*/}')
      .set('javascript.jsx', '{/*%s*/}')
      .set('typescriptreact', '{/*%s*/}')
      .set('typescript.tsx', '{/*%s*/}')
      .set('graphql', '//%s')
      .set('json', '//%s')
  end,
})

package({
  'Matt-A-Bennett/vim-surround-funk',
  config = function()
    if not rvim.plugin_installed('vim-surround-funk') then return end
    vim.g.surround_funk_create_mappings = 0
  end,
})

package({
  'danymat/neogen',
  event = { 'BufWinEnter' },
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    if not rvim.plugin_installed('neogen') then return end
    require('neogen').setup({ snippet_engine = 'luasnip' })
  end,
})

package({
  'chentoast/marks.nvim',
  config = function()
    if not rvim.plugin_installed('marks.nvim') then return end
    require('user.utils.highlights').plugin(
      'marks',
      { MarkSignHL = { link = 'Directory' }, MarkSignNumHL = { link = 'Directory' } }
    )
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
})

package({ 'psliwka/vim-dirtytalk', run = ':DirtytalkUpdate' })

package({ 'mizlan/iswap.nvim', event = 'BufRead' })

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
package({
  'junegunn/vim-easy-align',
  config = function()
    if not rvim.plugin_installed('vim-easy-align') then return end
  end,
  disable = true,
})

package({
  'jghauser/fold-cycle.nvim',
  config = function()
    if not rvim.rvim.plugin_installed('fold-cycle.nvim') then return end
    require('fold-cycle').setup()
  end,
  disable = true,
})
