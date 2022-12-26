local use = require('user.core.lazy').use
local conf = require('user.utils.plugins').load_conf

use({ 'razak17/zephyr-nvim', lazy = false })

use({ 'LunarVim/horizon.nvim' })

use({ 'goolord/alpha-nvim', lazy = false, config = conf('ui', 'alpha') })

use({
  'rcarriga/nvim-notify',
  event = 'VeryLazy',
  init = function()
    rvim.nnoremap('<leader>nn', '<cmd>Notifications<CR>', 'notify: show')
    rvim.nnoremap('<leader>nx', '<cmd>lua require("notify").dismiss()<CR>', 'notify: dismiss')
  end,
  config = conf('ui', 'notify'),
})

use({
  'nvim-lualine/lualine.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = conf('ui', 'lualine'),
})

use({
  'romainl/vim-cool',
  event = { 'BufRead', 'BufNewFile' },
  config = function() vim.g.CoolTotalMatches = 1 end,
})

use({
  'j-hui/fidget.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = function()
    require('fidget').setup({
      align = {
        bottom = false,
        right = true,
      },
      fmt = { stack_upwards = false },
    })
    rvim.augroup('CloseFidget', {
      {
        event = { 'VimLeavePre', 'LspDetach' },
        command = 'silent! FidgetClose',
      },
    })
  end,
})

use({
  'lukas-reineke/indent-blankline.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = conf('ui', 'indentline'),
})

use({ 'nvim-tree/nvim-web-devicons', event = 'VeryLazy' })

use({
  'nvim-neo-tree/neo-tree.nvim',
  cmd = { 'Neotree' },
  branch = 'main',
  init = function()
    rvim.nnoremap('<c-n>', '<cmd>Neotree toggle reveal<CR>', 'toggle tree', 'neo-tree.nvim')
  end,
  config = conf('ui', 'neo-tree'),
})

use({
  's1n7ax/nvim-window-picker',
  version = 'v1.*',
  event = 'VeryLazy',
  config = function()
    require('window-picker').setup({
      autoselect_one = true,
      include_current = false,
      filter_rules = {
        bo = {
          filetype = { 'neo-tree-popup', 'quickfix', 'incline' },
          buftype = { 'terminal', 'quickfix', 'nofile' },
        },
      },
      other_win_hl_color = require('user.utils.highlights').get('Visual', 'bg'),
    })
  end,
})

use({
  'lewis6991/gitsigns.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = conf('ui', 'gitsigns'),
})

use({ 'stevearc/dressing.nvim', event = 'VeryLazy', config = conf('ui', 'dressing') })

use({
  'kevinhwang91/nvim-ufo',
  event = { 'BufRead', 'BufNewFile' },
  dependencies = { 'kevinhwang91/promise-async' },
  config = conf('ui', 'ufo'),
})

use({
  'lukas-reineke/virt-column.nvim',
  event = { 'BufRead', 'BufNewFile' },
  config = function()
    require('user.utils.highlights').plugin('virt_column', {
      { VirtColumn = { bg = 'None', fg = { from = 'VertSplit', alter = -50 } } },
    })
    require('virt-column').setup({ char = '│' })
  end,
})

use({
  'uga-rosa/ccc.nvim',
  cmd = { 'CccHighlighterToggle', 'CccHighlighterEnable', 'CccHighlighterDisable' },
  init = function() rvim.nnoremap('<leader>oc', '<cmd>CccHighlighterToggle<CR>', 'ccc: toggle') end,
  config = function()
    require('ccc').setup({
      win_opts = { border = rvim.style.border.current },
      highlighter = {
        auto_enable = true,
        excludes = { 'dart', 'html', 'css', 'typescriptreact' },
      },
    })
  end,
})

use({
  'lukas-reineke/headlines.nvim',
  ft = { 'org', 'norg', 'markdown', 'yaml' },
  init = function()
    require('user.utils.highlights').plugin('Headlines', {
      { Headline1 = { background = '#003c30', foreground = 'White' } },
      { Headline2 = { background = '#00441b', foreground = 'White' } },
      { Headline3 = { background = '#084081', foreground = 'White' } },
      { Dash = { background = '#0b60a1', bold = true } },
    })
  end,
  config = function()
    require('headlines').setup({
      markdown = {
        headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
      },
      org = { headline_highlights = false },
      norg = { codeblock_highlight = false },
    })
  end,
})

use({
  'folke/todo-comments.nvim',
  cmd = { 'TodoTelescope', 'TodoTrouble', 'TodoQuickFix', 'TodoDots' },
  init = function()
    -- todo-comments.nvim
    rvim.nnoremap(
      '<leader>tj',
      function() require('todo-comments').jump_next() end,
      'todo-comments: next todo'
    )
    rvim.nnoremap(
      '<leader>tk',
      function() require('todo-comments').jump_prev() end,
      'todo-comments: prev todo'
    )
  end,
  config = function()
    require('todo-comments').setup({ highlight = { after = '' } })
    rvim.command(
      'TodoDots',
      string.format('TodoTelescope cwd=%s keywords=TODO,FIXME', rvim.get_config_dir())
    )
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
-- use({
--   'm-demare/hlargs.nvim',
--   config = function()
--     require('user.utils.highlights').plugin('hlargs', {
--       theme = {
--         ['*'] = { { Hlargs = { italic = true, foreground = '#A5D6FF' } } },
--         ['horizon'] = { { Hlargs = { italic = true, foreground = { from = 'Normal' } } } },
--       },
--     })
--     require('hlargs').setup({
--       excluded_argnames = {
--         declarations = { 'use', 'use_rocks', '_' },
--         usages = {
--           go = { '_' },
--           lua = { 'self', 'use', 'use_rocks', '_' },
--         },
--       },
--     })
--   end,
--   disable = true,
-- })
--
-- use({
--   'rainbowhxch/beacon.nvim',
--   config = function()
--     local beacon = require('beacon')
--     beacon.setup({
--       minimal_jump = 20,
--       ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
--       ignore_filetypes = {
--         'neo-tree',
--         'qf',
--         'NeogitCommitMessage',
--         'NeogitPopup',
--         'NeogitStatus',
--         'packer',
--         'trouble',
--       },
--     })
--     rvim.augroup('BeaconCmds', {
--       {
--         event = { 'BufReadPre' },
--         pattern = { '*.norg' },
--         command = function() beacon.beacon_off() end,
--       },
--     })
--   end,
--   disable = true,
-- })
--
-- use({
--   'mvllow/modes.nvim',
--   tag = 'v0.2.0',
--   config = function() require('modes').setup() end,
--   disable = true,
-- })
--
-- use({ 'fladson/vim-kitty', disable = true })
--
-- use({ 'mtdl9/vim-log-highlighting', disable = true })
--
-- use({
--   'itchyny/vim-highlighturl',
--   disable = true,
--   config = function() vim.g.highlighturl_guifg = require('user.utils.highlights').get('URL', 'fg') end,
-- })
--
-- use({
--   'levouh/tint.nvim',
--   event = 'BufRead',
--   disable = true,
--   config = function()
--     require('tint').setup({
--       tint = -30,
--       highlight_ignore_patterns = {
--         'winseparator',
--         'st.*',
--         'comment',
--         'panel.*',
--         'telescope.*',
--         'bqf.*',
--       },
--       window_ignore_function = function(win_id)
--         if vim.wo[win_id].diff or vim.fn.win_gettype(win_id) ~= '' then return true end
--         local buf = vim.api.nvim_win_get_buf(win_id)
--         local b = vim.bo[buf]
--         local ignore_bt = { 'terminal', 'prompt', 'nofile' }
--         local ignore_ft = {
--           'neo-tree',
--           'packer',
--           'diff',
--           'toggleterm',
--           'Neogit.*',
--           'Telescope.*',
--           'qf',
--         }
--         return rvim.any(b.bt, ignore_bt) or rvim.any(b.ft, ignore_ft)
--       end,
--     })
--   end,
-- })
