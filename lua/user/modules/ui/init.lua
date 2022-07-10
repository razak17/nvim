local utils = require('user.utils')
local conf = utils.load_conf

local ui = {}

ui['razak17/zephyr-nvim'] = {
  requires = { 'nvim-treesitter/nvim-treesitter', opt = true },
  local_path = 'personal',
}

ui['akinsho/bufferline.nvim'] = {
  config = conf('ui', 'bufferline'),
}

ui['nvim-lualine/lualine.nvim'] = {
  config = conf('ui', 'lualine'),
}

ui['kyazdani42/nvim-web-devicons'] = {
  config = conf('ui', 'nvim-web-devicons'),
}

ui['lukas-reineke/indent-blankline.nvim'] = {
  config = conf('ui', 'indentline'),
}

ui['lewis6991/gitsigns.nvim'] = {
  event = 'CursorHold',
  config = conf('ui', 'gitsigns'),
}

ui['rcarriga/nvim-notify'] = {
  cond = utils.not_headless, -- TODO: causes blocking output in headless mode
  config = conf('ui', 'notify'),
}

ui['stevearc/dressing.nvim'] = {
  event = 'BufWinEnter',
  config = function() end,
}

ui['lukas-reineke/headlines.nvim'] = {
  event = 'BufWinEnter',
  ft = { 'org', 'norg', 'markdown', 'yaml' },
  setup = conf('ui', 'headlines').setup,
  config = conf('ui', 'headlines').config,
}

ui['rainbowhxch/beacon.nvim'] = {
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
        event = 'BufReadPre',
        pattern = '*.norg',
        command = function()
          beacon.beacon_off()
        end,
      },
    })
  end,
}

ui['zbirenbaum/neodim'] = {
  config = function()
    require('neodim').setup({
      blend_color = require('zephyr.utils').get('Normal', 'bg'),
      alpha = 0.60,
      hide = {
        virtual_text = false,
        signs = false,
        underline = false,
      },
    })
  end,
}

ui['nvim-neo-tree/neo-tree.nvim'] = {
  branch = 'v2.x',
  config = conf('ui', 'neo-tree'),
}

ui['MunifTanjim/nui.nvim'] = {}

ui['s1n7ax/nvim-window-picker'] = {
  tag = '1.*',
  config = conf('ui', 'window-picker'),
}

ui['itchyny/vim-highlighturl'] = {
  config = function()
    vim.g.highlighturl_guifg = require('zephyr.utils').get('URL', 'fg')
  end,
}

ui['EdenEast/nightfox.nvim'] = {}

ui['NTBBloodbath/doom-one.nvim'] = {
  config = function()
    require('doom-one').setup({
      pumblend = {
        enable = true,
        transparency_amount = 3,
      },
    })
  end,
  disable = true,
}

ui['RRethy/vim-illuminate'] = {
  config = function()
    vim.g.Illuminate_ftblacklist = {
      'alpha',
      'NvimTree',
      'dashboard',
      'neo-tree',
      'qf',
      'lspinfo',
      'lsp-installer',
    }
    rvim.nnoremap('<a-n>', ':lua require"illuminate".next_reference{wrap=true}<cr>')
    rvim.nnoremap('<a-p>', ':lua require"illuminate".next_reference{reverse=true,wrap=true}<cr>')
  end,
}

ui['m-demare/hlargs.nvim'] = {
  config = function()
    require('zephyr.utils').plugin('hlargs', {
      Hlargs = { italic = true, bold = false, foreground = '#A5D6FF' },
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
}

ui['j-hui/fidget.nvim'] = {
  config = function()
    require('fidget').setup()
  end,
}

ui['kevinhwang91/nvim-ufo'] = {
  requires = 'kevinhwang91/promise-async',
  config = conf('ui', 'ufo'),
}

ui['goolord/alpha-nvim'] = { config = conf('ui', 'alpha') }

return ui
