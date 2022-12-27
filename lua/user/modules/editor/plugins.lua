local use = require('user.core.lazy').use
local conf = require('user.utils.plugins').load_conf

-- nvim-cmp
use({
  'hrsh7th/nvim-cmp',
  event = 'InsertEnter',
  config = conf('editor', 'cmp'),
  dependencies = {
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
    { 'saadparwaiz1/cmp_luasnip' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/cmp-nvim-lsp-signature-help' },
    { 'hrsh7th/cmp-emoji' },
    { 'dmitmel/cmp-cmdline-history' },
    { 'amarakon/nvim-cmp-buffer-lines' },
    { 'lukas-reineke/cmp-rg' },
    { 'rcarriga/cmp-dap' },
    {
      'petertriho/cmp-git',
      config = function()
        require('cmp_git').setup({
          filetypes = { 'gitcommit', 'NeogitCommitMessage' },
        })
      end,
    },
    {
      'uga-rosa/cmp-dictionary',
      config = function()
        -- NOTE: run :CmpDictionaryUpdate to update dictionary
        require('cmp_dictionary').setup({
          async = true,
          dic = {
            -- Refer to install script
            ['*'] = join_paths(rvim.get_runtime_dir(), 'site', 'spell', 'dictionary.txt'),
          },
        })
      end,
    },
  },
})

use({
  'L3MON4D3/LuaSnip',
  event = 'InsertEnter',
  dependencies = { 'rafamadriz/friendly-snippets' },
  init = function() rvim.nnoremap('<leader>S', '<cmd>LuaSnipEdit<CR>', 'LuaSnip: edit snippet') end,
  config = conf('editor', 'luasnip'),
})

use({
  'xiyaowong/accelerated-jk.nvim',
  event = 'VeryLazy',
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
  event = 'VeryLazy',
  config = function()
    require('nvim-surround').setup({
      move_cursor = false,
      keymaps = { visual = 'S' },
    })
  end,
})

use({
  'numToStr/Comment.nvim',
  event = 'VeryLazy',
  config = function()
    local utils = require('Comment.utils')
    require('Comment').setup({
      pre_hook = function(ctx)
        local location = nil
        if ctx.ctype == utils.ctype.blockwise then
          location = require('ts_context_commentstring.utils').get_cursor_location()
        elseif ctx.cmotion == utils.cmotion.v or ctx.cmotion == utils.cmotion.V then
          location = require('ts_context_commentstring.utils').get_visual_start_location()
        end
        return require('ts_context_commentstring.internal').calculate_commentstring({
          key = ctx.ctype == utils.ctype.linewise and '__default' or '__multiline',
          location = location,
        })
      end,
    })
  end,
})

use({ 'JoosepAlviste/nvim-ts-context-commentstring' })

use({ 'psliwka/vim-dirtytalk', build = ':DirtytalkUpdate' })

use({
  'axelvc/template-string.nvim',
  ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  config = function()
    require('template-string').setup({
      remove_template_string = true, -- remove backticks when there are no template string
    })
  end,
})

use({
  'aarondiel/spread.nvim',
  init = function()
    rvim.nnoremap('gS', function() require('spread').out() end, 'spread: expand')
    rvim.nnoremap('gJ', function() require('spread').combine() end, 'spread: combine')
  end,
})

use({
  'kazhala/close-buffers.nvim',
  init = function()
    rvim.nnoremap(
      '<leader>c',
      function() require('close_buffers').delete({ type = 'this' }) end,
      'close buffer'
    )
    rvim.nnoremap(
      '<leader>bc',
      function() require('close_buffers').wipe({ type = 'other' }) end,
      'close others'
    )
    rvim.nnoremap(
      '<leader>bx',
      function() require('close_buffers').wipe({ type = 'all', force = true }) end,
      'close others'
    )
  end,
})

use({
  'karb94/neoscroll.nvim', -- NOTE: alternative: 'declancm/cinnamon.nvim'
  event = 'VeryLazy',
  config = function() require('neoscroll').setup({ hide_cursor = true }) end,
})

use({
  'nguyenvukhang/nvim-toggler',
  event = 'VeryLazy',
  init = function()
    rvim.nnoremap(
      '<leader>ii',
      '<cmd>lua require("nvim-toggler").toggle()<CR>',
      'nvim-toggler: toggle'
    )
  end,
  config = function()
    require('nvim-toggler').setup({
      inverses = {
        ['vim'] = 'emacs',
        ['let'] = 'const',
        ['margin'] = 'padding',
        ['-'] = '+',
        ['onClick'] = 'onSubmit',
        ['public'] = 'private',
      },
      remove_default_keybinds = true,
    })
  end,
})

use({
  'mizlan/iswap.nvim',
  event = { 'BufRead', 'BufNewFile' },
  init = function()
    rvim.nnoremap('<leader>ia', '<Cmd>ISwap<CR>', 'iswap: swap any')
    rvim.nnoremap('<leader>iw', '<Cmd>ISwapWith<CR>', 'iswap: swap with')
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------

-- use({ 'monaqa/dial.nvim', config = conf('editor', 'dial') })
--
-- use({
--   'chentoast/marks.nvim',
--   init = function()
--     rvim.nnoremap('<leader>mb', '<Cmd>MarksListBuf<CR>', 'marks: list buffer')
--     rvim.nnoremap('<leader>mg', '<Cmd>MarksQFListGlobal<CR>', 'marks: list global')
--     rvim.nnoremap('<leader>m0', '<Cmd>BookmarksQFList 0<CR>', 'marks: list bookmark')
--   end,
--   config = function()
--     require('user.utils.highlights').plugin('marks', {
--       { MarkSignHL = { link = 'Directory' } },
--       { MarkSignNumHL = { link = 'Directory' } },
--     })
--     require('marks').setup({
--       force_write_shada = false, -- This can cause data loss
--       excluded_filetypes = { 'NeogitStatus', 'NeogitCommitMessage', 'toggleterm' },
--       bookmark_0 = {
--         sign = '⚑',
--         virt_text = '',
--       },
--       mappings = {
--         annotate = 'm?',
--       },
--     })
--   end,
-- })
