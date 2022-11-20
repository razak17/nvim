local utils = require('user.utils.plugins')
local conf = utils.load_conf
local use = require('user.core.packer').use

use({
  'razak17/zephyr-nvim',
  requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  local_path = 'personal',
})

use({ 'LunarVim/horizon.nvim' })

use({ 'goolord/alpha-nvim', config = conf('ui', 'alpha') })

use({ 'rcarriga/nvim-notify', config = conf('ui', 'notify') })

use({ 'nvim-lualine/lualine.nvim', config = conf('ui', 'lualine') })

use({ 'romainl/vim-cool', event = 'BufRead', config = function() vim.g.CoolTotalMatches = 1 end })

use({
  'j-hui/fidget.nvim',
  config = function()
    require('fidget').setup({
      align = {
        bottom = true,
        right = true,
      },
      fmt = {
        stack_upwards = false,
      },
    })
    rvim.augroup('CloseFidget', {
      {
        event = { 'VimLeavePre', 'LspDetach' },
        command = 'silent! FidgetClose',
      },
    })
  end,
})

use({ 'lukas-reineke/indent-blankline.nvim', config = conf('ui', 'indentline') })

use({ 'MunifTanjim/nui.nvim' })

use({
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'main',
  config = conf('ui', 'neo-tree'),
  requires = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons',
    {
      's1n7ax/nvim-window-picker',
      tag = 'v1.*',
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
    },
  },
})

use({
  'lewis6991/gitsigns.nvim',
  event = 'BufWinEnter',
  config = conf('ui', 'gitsigns'),
})

use({ 'stevearc/dressing.nvim', after = 'telescope.nvim', config = conf('ui', 'dressing') })

use({
  'kevinhwang91/nvim-ufo',
  event = 'BufRead',
  requires = 'kevinhwang91/promise-async',
  config = conf('ui', 'ufo'),
})

use({
  'razak17/cybu.nvim',
  local_path = 'personal',
  config = function()
    require('cybu').setup({
      position = {
        relative_to = 'win',
        anchor = 'topright',
      },
      style = { border = 'single', hide_buffer_id = true },
      exclude = {
        'neo-tree',
        'qf',
        'lspinfo',
        'alpha',
        'NvimTree',
        'DressingInput',
        'dashboard',
        'neo-tree',
        'neo-tree-popup',
        'lsp-installer',
        'TelescopePrompt',
        'harpoon',
        'packer',
        'mason.nvim',
        'help',
        'CommandTPrompt',
      },
    })
  end,
})

use({
  'lukas-reineke/virt-column.nvim',
  event = 'BufRead',
  config = function()
    require('user.utils.highlights').plugin('virt_column', {
      { VirtColumn = { bg = 'None', fg = { from = 'VertSplit', alter = -50 } } },
    })
    require('virt-column').setup({ char = '│' })
  end,
})

use({
  'uga-rosa/ccc.nvim',
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
  event = 'BufRead',
  ft = { 'org', 'norg', 'markdown', 'yaml' },
  setup = function()
    -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
    -- NOTE: this must be set in the setup function or it will crash nvim...
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
      org = {
        headline_highlights = false,
      },
      norg = { codeblock_highlight = false },
    })
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({
  'm-demare/hlargs.nvim',
  config = function()
    require('user.utils.highlights').plugin('hlargs', {
      theme = {
        ['*'] = { { Hlargs = { italic = true, foreground = '#A5D6FF' } } },
        ['horizon'] = { { Hlargs = { italic = true, foreground = { from = 'Normal' } } } },
      },
    })
    require('hlargs').setup({
      excluded_argnames = {
        declarations = { 'use', 'use_rocks', '_' },
        usages = {
          go = { '_' },
          lua = { 'self', 'use', 'use_rocks', '_' },
        },
      },
    })
  end,
  disable = true,
})

use({
  'rainbowhxch/beacon.nvim',
  config = function()
    local beacon = require('beacon')
    beacon.setup({
      minimal_jump = 20,
      ignore_buffers = { 'terminal', 'nofile', 'neorg://Quick Actions' },
      ignore_filetypes = {
        'neo-tree',
        'qf',
        'NeogitCommitMessage',
        'NeogitPopup',
        'NeogitStatus',
        'packer',
        'trouble',
      },
    })
    rvim.augroup('BeaconCmds', {
      {
        event = { 'BufReadPre' },
        pattern = { '*.norg' },
        command = function() beacon.beacon_off() end,
      },
    })
  end,
  disable = true,
})

use({
  'mvllow/modes.nvim',
  tag = 'v0.2.0',
  config = function() require('modes').setup() end,
  disable = true,
})

use({ 'fladson/vim-kitty', disable = true })

use({ 'mtdl9/vim-log-highlighting', disable = true })

use({
  'folke/todo-comments.nvim',
  disable = true,
  after = 'nvim-treesitter',
  requires = { 'nvim-treesitter' },
  config = function()
    require('todo-comments').setup({ highlight = { after = '' } })
    rvim.command(
      'TodoDots',
      string.format('TodoQuickFix cwd=%s keywords=TODO,FIXME', vim.g.vim_dir)
    )
  end,
})

use({
  'itchyny/vim-highlighturl',
  disable = true,
  config = function() vim.g.highlighturl_guifg = require('user.utils.highlights').get('URL', 'fg') end,
})

use({
  'levouh/tint.nvim',
  event = 'BufRead',
  disable = true,
  config = function()
    require('tint').setup({
      tint = -30,
      highlight_ignore_patterns = {
        'winseparator',
        'st.*',
        'comment',
        'panel.*',
        'telescope.*',
        'bqf.*',
      },
      window_ignore_function = function(win_id)
        if vim.wo[win_id].diff or vim.fn.win_gettype(win_id) ~= '' then return true end
        local buf = vim.api.nvim_win_get_buf(win_id)
        local b = vim.bo[buf]
        local ignore_bt = { 'terminal', 'prompt', 'nofile' }
        local ignore_ft = {
          'neo-tree',
          'packer',
          'diff',
          'toggleterm',
          'Neogit.*',
          'Telescope.*',
          'qf',
        }
        return rvim.any(b.bt, ignore_bt) or rvim.any(b.ft, ignore_ft)
      end,
    })
  end,
})
