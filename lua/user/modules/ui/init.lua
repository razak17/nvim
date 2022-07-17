local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload

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
  config = block_reload(conf('ui', 'notify')),
}

ui['stevearc/dressing.nvim'] = {
  event = 'BufWinEnter',
  config = function() end,
}

ui['lukas-reineke/headlines.nvim'] = {
  event = 'BufWinEnter',
  ft = { 'org', 'norg', 'markdown', 'yaml' },
  setup = function()
    -- https://observablehq.com/@d3/color-schemes?collection=@d3/d3-scale-chromatic
    -- NOTE: this must be set in the setup function or it will crash nvim...
    require('zephyr.utils').plugin('Headlines', {
      Headline1 = { background = '#003c30', foreground = 'White' },
      Headline2 = { background = '#00441b', foreground = 'White' },
      Headline3 = { background = '#084081', foreground = 'White' },
      Dash = { background = '#0b60a1', bold = true },
    })
  end,
  config = function()
    require('headlines').setup({
      markdown = {
        headline_highlights = { 'Headline1', 'Headline2', 'Headline3' },
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
      other_win_hl_color = require('zephyr.utils').get('Visual', 'bg'),
    })
  end,
}

ui['itchyny/vim-highlighturl'] = {
  config = function() vim.g.highlighturl_guifg = require('zephyr.utils').get('URL', 'fg') end,
}

ui['j-hui/fidget.nvim'] = {
  config = function() require('fidget').setup() end,
}

ui['kevinhwang91/nvim-ufo'] = {
  requires = 'kevinhwang91/promise-async',
  config = conf('ui', 'ufo'),
}

ui['goolord/alpha-nvim'] = { config = conf('ui', 'alpha') }

ui['fladson/vim-kitty'] = {}

-- Syntax
ui['mtdl9/vim-log-highlighting'] = {}

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
  disable = true,
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
        command = function() beacon.beacon_off() end,
      },
    })
  end,
  disable = true,
}

ui['EdenEast/nightfox.nvim'] = { disable = true }

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

return ui
