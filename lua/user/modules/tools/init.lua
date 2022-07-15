local utils = require('user.utils.plugins')
local conf = utils.load_conf
local block_reload = utils.block_reload

local tools = {}

tools['folke/which-key.nvim'] = {
  config = conf('tools', 'which_key'),
}

tools['sindrets/diffview.nvim'] = {
  event = 'BufReadPre',
  setup = function()
    rvim.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>', 'diffview: diff HEAD')
    rvim.nnoremap('<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', 'diffview: file history')
    rvim.vnoremap('gh', [[:'<'>DiffviewFileHistory<CR>]], 'diffview: file history')
  end,
  config = function()
    require('diffview').setup({
      hooks = {
        diff_buf_read = function()
          vim.opt_local.wrap = false
          vim.opt_local.list = false
          vim.opt_local.colorcolumn = ''
        end,
      },
      enhanced_diff_hl = true,
      keymaps = {
        view = { q = '<Cmd>DiffviewClose<CR>' },
        file_panel = { q = '<Cmd>DiffviewClose<CR>' },
        file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
      },
    })
  end,
}

tools['mbbill/undotree'] = {
  event = 'BufWinEnter',
  cmd = 'UndotreeToggle',
  setup = function() rvim.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle') end,
  config = function()
    vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
  end,
}

tools['ahmedkhalf/project.nvim'] = {
  config = conf('tools', 'project'),
}

tools['npxbr/glow.nvim'] = {
  run = ':GlowInstall',
  branch = 'main',
  disable = true,
}

tools['kkoomen/vim-doge'] = {
  run = ':call doge#install()',
  config = function() vim.g.doge_mapping = '<Leader>lD' end,
  disable = true,
}

tools['numToStr/FTerm.nvim'] = {
  event = { 'BufWinEnter' },
  config = conf('tools', 'fterm'),
}

tools['diepm/vim-rest-console'] = {
  event = 'VimEnter',
  disable = true,
}

tools['iamcco/markdown-preview.nvim'] = {
  run = function() vim.fn['mkdp#util#install']() end,
  ft = { 'markdown' },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
  disable = true,
}

tools['brooth/far.vim'] = {
  event = { 'BufRead' },
  config = function()
    vim.g['far#source'] = 'rg'
    vim.g['far#enable_undo'] = 1
    require('which-key').register({
      ['<leader>Ff'] = { ':Farr --source=vimgrep<cr>', 'far: replace in File' },
      ['<leader>Fd'] = { ':Fardo<cr>', 'far: do' },
      ['<leader>Fi'] = { ':Farf<cr>', 'far: search iteratively' },
      ['<leader>Fr'] = { ':Farr --source=rgnvim<cr>', 'far: replace in project' },
      ['<leader>Fu'] = { ':Farundo<cr>', 'far: undo' },
      ['<leader>FU'] = { ':UpdateRemotePlugins<cr>', 'far: update remote' },
    })
  end,
}

tools['Tastyep/structlog.nvim'] = {}

tools['AckslD/nvim-neoclip.lua'] = {
  config = function()
    require('neoclip').setup({
      enable_persistent_history = false,
      keys = {
        telescope = {
          i = { select = '<c-p>', paste = '<CR>', paste_behind = '<c-k>' },
          n = { select = 'p', paste = '<CR>', paste_behind = 'P' },
        },
      },
    })
    local function clip() require('telescope').extensions.neoclip.default(rvim.telescope.dropdown()) end

    require('which-key').register({
      ['<leader>fN'] = { clip, 'neoclip: open yank history' },
    })
  end,
}

tools['nvim-telescope/telescope.nvim'] = {
  branch = '0.1.x',
  config = conf('tools', 'telescope'),
  requires = {
    {
      'natecraddock/telescope-zf-native.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('zf-native') end,
    },
  },
}

tools['kkharji/sqlite.lua'] = {}

tools['ilAYAli/scMRU.nvim'] = {}

tools['nvim-telescope/telescope-ui-select.nvim'] = {}

tools['nvim-telescope/telescope-dap.nvim'] = {}

tools['nvim-telescope/telescope-file-browser.nvim'] = {}

tools['nvim-telescope/telescope-media-files.nvim'] = {}

tools['jvgrootveld/telescope-zoxide'] = {}

tools['rmagatti/auto-session'] = {
  config = function()
    local fn = vim.fn
    local fmt = string.format
    require('auto-session').setup({
      log_level = 'error',
      auto_session_root_dir = join_paths(rvim.get_cache_dir(), 'session/auto/'),
      -- Do not enable auto restoration in my projects directory, I'd like to choose projects myself
      auto_restore_enabled = not vim.startswith(fn.getcwd(), vim.env.DEV_HOME),
      auto_session_suppress_dirs = {
        vim.env.HOME,
        fmt('%s/Desktop', vim.env.HOME),
        fmt('%s/Desktop', vim.env.HOME),
        fmt('%s/site/pack/packer/opt/*', rvim.get_runtime_dir()),
        fmt('%s/site/pack/packer/start/*', rvim.get_runtime_dir()),
      },
      auto_session_use_git_branch = false, -- This cause inconsistent results
    })
    require('which-key').register({
      ['<leader>sl'] = { ':RestoreSession<cr>', 'auto-session: restore' },
      ['<leader>ss'] = { ':SaveSession<cr>', 'auto-session: save' },
    })
  end,
}

tools['phaazon/hop.nvim'] = {
  tag = 'v2.*',
  keys = { { 'n', 's' }, 'f', 'F' },
  config = conf('tools', 'hop'),
}

tools['lewis6991/impatient.nvim'] = {}

tools['moll/vim-bbye'] = {
  event = 'BufWinEnter',
  config = function()
    require('which-key').register({
      ['<leader>c'] = { ':Bdelete!<cr>', 'close buffer' },
      ['<leader>bx'] = { ':bufdo :Bdelete<cr>', 'close all' },
      ['<leader>q'] = { '<Cmd>Bwipeout<CR>', 'wipe buffer' },
    })
  end,
}

tools['tpope/vim-apathy'] = {}

tools['tpope/vim-projectionist'] = {
  config = conf('tools', 'vim-projectionist'),
}

tools['nvim-lua/plenary.nvim'] = {}

tools['nvim-lua/popup.nvim'] = {}

tools['NTBBloodbath/rest.nvim'] = {
  requires = { 'nvim-lua/plenary.nvim' },
  ft = { 'http', 'json' },
  config = function()
    require('rest-nvim').setup({
      -- Open request results in a horizontal split
      result_split_horizontal = true,
      -- Skip SSL verification, useful for unknown certificates
      skip_ssl_verification = true,
      -- Jump to request line on run
      jump_to_request = false,
      custom_dynamic_variables = {},
    })

    rvim.nnoremap('<leader>rr', '<Plug>RestNvim', 'rest: run')
    rvim.nnoremap('<leader>rp', '<Plug>RestNvimPreview', 'rest: run')
    rvim.nnoremap('<leader>rl', '<Plug>RestNvimLast', 'rest: run')
  end,
}

tools['michaelb/sniprun'] = {
  event = 'BufWinEnter',
  config = conf('tools', 'sniprun'),
  run = 'bash ./install.sh',
}

tools['vuki656/package-info.nvim'] = {
  event = 'BufWinEnter',
  ft = { 'json' },
  config = conf('tools', 'package-info'),
  requires = 'MunifTanjim/nui.nvim',
  disable = true,
}

tools['nvim-neotest/neotest'] = {
  config = conf('tools', 'neotest'),
  requires = {
    'rcarriga/neotest-plenary',
    'rcarriga/neotest-vim-test',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
  },
}

tools['smjonas/inc-rename.nvim'] = {
  config = function()
    require('inc_rename').setup({
      hl_group = 'Visual',
    })
    vim.keymap.set(
      'n',
      '<leader>rn',
      function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
      { expr = true, silent = false, desc = 'lsp: incremental rename' }
    )
  end,
}

tools['AndrewRadev/linediff.vim'] = {
  cmd = 'Linediff',
}

tools['Djancyp/cheat-sheet'] = {
  config = function()
    require('cheat-sheet').setup({
      auto_fill = {
        current_word = false,
      },
      main_win = {
        border = 'single',
      },
      input_win = {
        border = 'single',
      },
    })
    require('which-key').register({
      ['<localleader>s'] = { ':CheatSH<CR>', 'cheat-sheet' },
    })
  end,
}

tools['SmiteshP/nvim-navic'] = {
  requires = 'neovim/nvim-lspconfig',
  config = function()
    vim.g.navic_silence = true
    local highlights = require('zephyr.utils')
    local s = rvim.style
    local misc = s.icons.misc

    highlights.set_hl('NavicText', { bold = false })
    highlights.set_hl('NavicSeparator', { link = 'Directory' })
    local icons = rvim.map(function(icon, key)
      highlights.set_hl(('NavicIcons%s'):format(key), { link = rvim.lsp.kind_highlights[key] })
      return icon .. ' '
    end, s.codicons.kind)

    require('nvim-navic').setup({
      icons = icons,
      highlight = true,
      depth_limit_indicator = misc.ellipsis,
      separator = (' %s '):format(misc.arrow_right),
    })
  end,
}

tools['vhyrro/neorg'] = {
  requires = { 'vhyrro/neorg-telescope' },
  config = conf('tools', 'neorg'),
  disable = true,
}

tools['kevinhwang91/nvim-bqf'] = {
  ft = 'qf',
}

tools['anuvyklack/hydra.nvim'] = {
  requires = 'anuvyklack/keymap-layer.nvim',
  config = block_reload(conf('tools', 'hydra')),
}

return tools
