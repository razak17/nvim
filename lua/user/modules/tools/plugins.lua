local use = require('user.core.packer').use
local conf = require('user.utils.plugins').load_conf

-- Debugging
use({
  'mfussenegger/nvim-dap',
  module = 'dap',
  tag = '*',
  config = conf('tools', 'dap'),
  requires = {
    {
      'rcarriga/nvim-dap-ui',
      config = function()
        local dapui = require('dapui')
        require('dapui').setup({
          windows = { indent = 2 },
          floating = {
            border = rvim.style.border.current,
          },
        })
        local dap = require('dap')
        -- NOTE: this opens dap UI automatically when dap starts
        dap.listeners.after.event_initialized['dapui_config'] = function()
          dapui.open()
          vim.api.nvim_exec_autocmds('User', { pattern = 'DapStarted' })
        end
        dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
        dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
      end,
    },
    {
      'theHamsta/nvim-dap-virtual-text',
      config = function()
        require('nvim-dap-virtual-text').setup({
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          all_frames = true,
        })
      end,
    },
  },
})

use({
  'nvim-telescope/telescope.nvim',
  branch = 'master', -- '0.1.x',
  config = conf('tools', 'telescope'),
  requires = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-lua/popup.nvim' },
    { 'kkharji/sqlite.lua' },
    {
      'jvgrootveld/telescope-zoxide',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('zoxide') end,
    },
    {
      'smartpde/telescope-recent-files',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('recent_files') end,
    },
    {
      'nvim-telescope/telescope-media-files.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('media_files') end,
    },
    {
      'nvim-telescope/telescope-dap.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('dap') end,
    },
    {
      'natecraddock/telescope-zf-native.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('zf-native') end,
    },
    {
      'nvim-telescope/telescope-ui-select.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('ui-select') end,
    },
    {
      'benfowler/telescope-luasnip.nvim',
      after = 'telescope.nvim',
      config = function() require('telescope').load_extension('luasnip') end,
    },
    {
      'nvim-telescope/telescope-frecency.nvim',
      after = 'telescope.nvim',
      requires = { { 'kkharji/sqlite.lua', module = 'sqlite' } },
      config = function() require('telescope').load_extension('frecency') end,
    },
    {
      'ThePrimeagen/harpoon',
      config = function()
        require('harpoon').setup({
          menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
            borderchars = rvim.style.border.common,
          },
        })
        require('telescope').load_extension('harpoon')
      end,
    },
  },
})

use({
  'gbprod/yanky.nvim',
  keys = { 'p', 'P', '<localleader>p' },
  requires = { { 'kkharji/sqlite.lua', module = 'sqlite' } },
  config = conf('tools', 'yanky'),
})

use({
  'ahmedkhalf/project.nvim',
  after = 'telescope.nvim',
  config = function()
    require('project_nvim').setup({
      active = true,
      manual_mode = false,
      detection_methods = { 'pattern', 'lsp' },
      patterns = {
        '.git',
        '.hg',
        '.svn',
        'Makefile',
        'package.json',
        '.luacheckrc',
        '.stylua.toml',
      },
      show_hidden = false,
      silent_chdir = true,
      ignore_lsp = { 'null-ls' },
      datapath = rvim.get_cache_dir(),
    })
    require('telescope').load_extension('projects')
  end,
})

use({
  'numToStr/FTerm.nvim',
  config = function()
    local fterm = require('FTerm')
    fterm.setup({ dimensions = { height = 0.8, width = 0.9 } })
  end,
})

use({
  'ggandor/leap.nvim',
  keys = { { 'n', 's' } },
  config = function()
    require('user.utils.highlights').plugin('leap', {
      theme = {
        ['*'] = {
          { LeapBackdrop = { fg = '#707070' } },
        },
        horizon = {
          { LeapLabelPrimary = { bg = 'NONE', fg = '#ccff88', italic = true } },
          { LeapLabelSecondary = { bg = 'NONE', fg = '#99ccff' } },
          { LeapLabelSelected = { bg = 'NONE', fg = 'Magenta' } },
        },
      },
    })
    require('leap').setup({
      equivalence_classes = { ' \t\r\n', '([{', ')]}', '`"\'' },
    })
    rvim.nnoremap('s', function()
      require('leap').leap({
        target_windows = vim.tbl_filter(
          function(win) return rvim.empty(vim.fn.win_gettype(win)) end,
          vim.api.nvim_tabpage_list_wins(0)
        ),
      })
    end)
  end,
})

use({
  'ggandor/flit.nvim',
  keys = { { 'n', 'f' } },
  wants = { 'leap.nvim' },
  after = 'leap.nvim',
  config = function()
    require('flit').setup({
      labeled_modes = 'nvo',
      multiline = false,
    })
  end,
})

use({
  'SmiteshP/nvim-navic',
  event = 'BufRead',
  requires = 'neovim/nvim-lspconfig',
  config = function()
    vim.g.navic_silence = true
    local highlights = require('user.utils.highlights')
    local s = rvim.style
    local misc = s.icons.misc
    require('user.utils.highlights').plugin('navic', {
      { NavicText = { bold = false } },
      { NavicSeparator = { link = 'Directory' } },
    })
    local icons = rvim.map(function(icon, key)
      highlights.set(('NavicIcons%s'):format(key), { link = rvim.lsp.kind_highlights[key] })
      return icon .. ' '
    end, s.codicons.kind)
    require('nvim-navic').setup({
      icons = icons,
      highlight = true,
      depth_limit_indicator = misc.ellipsis,
      separator = (' %s '):format(misc.arrow_right),
    })
  end,
})

use({ 'nvim-lua/plenary.nvim' })

use({ 'lewis6991/impatient.nvim' })

use({ 'folke/which-key.nvim', config = conf('tools', 'which-key') })

use({
  'mbbill/undotree',
  event = 'BufRead',
  config = function()
    vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_SplitWidth = 35
  end,
})

use({
  'iamcco/markdown-preview.nvim',
  run = function() vim.fn['mkdp#util#install']() end,
  ft = { 'markdown' },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
})

use({
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  config = function()
    require('bqf').setup({
      preview = { border_chars = rvim.style.border.bqf },
    })
  end,
})

use({
  'is0n/jaq-nvim',
  event = 'BufRead',
  config = function()
    require('jaq-nvim').setup({
      cmds = {
        default = 'term',
        external = {
          typescript = 'ts-node %',
          javascript = 'node %',
          python = 'python %',
          rust = 'cargo run',
          cpp = 'g++ % -o $fileBase && ./$fileBase',
          go = 'go run %',
        },
      },
      behavior = { startinsert = true },
      terminal = {
        position = 'vert',
        size = 60,
      },
    })
    rvim.augroup('JaqConfig', {
      {
        event = { 'Filetype' },
        pattern = { 'Jaq' },
        command = function() vim.api.nvim_win_set_config(0, { border = rvim.style.border.current }) end,
      },
    })
  end,
})

use({
  'rmagatti/auto-session',
  event = 'VimEnter',
  config = function()
    local fmt = string.format
    require('auto-session').setup({
      log_level = 'error',
      auto_session_root_dir = join_paths(rvim.get_cache_dir(), 'session/auto/'),
      -- Do not enable auto restoration in my projects directory, I'd like to choose projects myself
      auto_restore_enabled = not vim.startswith(vim.fn.getcwd(), vim.env.DEV_HOME),
      auto_session_suppress_dirs = {
        vim.env.HOME,
        fmt('%s/Desktop', vim.env.HOME),
        fmt('%s/site/pack/packer/opt/*', rvim.get_runtime_dir()),
        fmt('%s/site/pack/packer/start/*', rvim.get_runtime_dir()),
      },
      auto_session_use_git_branch = false, -- This cause inconsistent results
    })
  end,
})

use({
  'nvim-neotest/neotest',
  config = function()
    require('neotest').setup({
      diagnostic = { enabled = false },
      icons = { running = rvim.style.icons.misc.clock },
      floating = { border = rvim.style.border.current },
      adapters = {
        require('neotest-plenary'),
        require('neotest-python'),
      },
    })
  end,
  requires = {
    'rcarriga/neotest-plenary',
    'rcarriga/neotest-vim-test',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },
})

use({ 'turbio/bracey.vim', ft = { 'html' }, run = 'npm install --prefix server' })

use({
  '0x100101/lab.nvim',
  ft = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  event = { 'InsertEnter' },
  run = 'cd js && npm ci',
  requires = { 'nvim-lua/plenary.nvim' },
  config = function() require('lab').setup() end,
})

use({
  'Saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  requires = { 'nvim-lua/plenary.nvim' },
  config = function()
    local crates = require('crates')
    crates.setup({
      popup = {
        -- autofocus = true,
        style = 'minimal',
        border = 'single',
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
      },
      null_ls = {
        enabled = true,
        name = 'crates.nvim',
      },
    })
    local ok, which_key = rvim.safe_require('which-key')
    if ok then which_key.register({ ['<localleader>'] = { c = { name = 'Crates' } } }) end
    local nnoremap = rvim.nnoremap
    local with_desc = function(desc) return { buffer = 0, desc = desc } end
    nnoremap('<localleader>ct', crates.toggle, with_desc('crates: toggle'))
    nnoremap('<localleader>cu', crates.update_crate, with_desc('crates: update'))
    nnoremap('<localleader>cU', crates.upgrade_crate, with_desc('crates: upgrade'))
    nnoremap('<localleader>ca', crates.update_all_crates, with_desc('crates: update all'))
    nnoremap('<localleader>cA', crates.upgrade_all_crates, with_desc('crates: upgrade all'))
    nnoremap('<localleader>ch', crates.open_homepage, with_desc('crates: open home'))
    nnoremap('<localleader>cr', crates.open_repository, with_desc('crates: open repo'))
    nnoremap('<localleader>cd', crates.open_documentation, with_desc('crates: open doc'))
    nnoremap('<localleader>cc', crates.open_crates_io, with_desc('crates: open crates.io'))
    nnoremap('<localleader>ci', crates.show_popup, with_desc('crates: info'))
    nnoremap('<localleader>cv', crates.show_versions_popup, with_desc('crates: versions'))
    nnoremap('<localleader>cf', crates.show_features_popup, with_desc('crates: features'))
    nnoremap('<localleader>cD', crates.show_dependencies_popup, with_desc('crates: dependencies'))
  end,
})

use({
  'razak17/package-info.nvim',
  event = { 'BufRead package.json' },
  requires = { 'MunifTanjim/nui.nvim' },
  config = function()
    local package_info = require('package-info')
    package_info.setup({
      autostart = false,
      package_manager = 'yarn',
    })
    local ok, which_key = rvim.safe_require('which-key')
    if ok then which_key.register({ ['<localleader>'] = { p = { name = 'Package Info' } } }) end
    local nnoremap = rvim.nnoremap
    local with_desc = function(desc) return { buffer = 0, desc = desc } end
    nnoremap('<localleader>pt', package_info.toggle, with_desc('package-info: toggle'))
    nnoremap('<localleader>pu', package_info.update, with_desc('package-info: update'))
    nnoremap('<localleader>pd', package_info.delete, with_desc('package-info: delete'))
    nnoremap('<localleader>pi', package_info.install, with_desc('package-info: install new'))
    nnoremap(
      '<localleader>pc',
      package_info.change_version,
      with_desc('package-info: change version')
    )
  end,
})

use({ 'shortcuts/no-neck-pain.nvim', module = 'no-neck-pain' })

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
use({ 'AndrewRadev/linediff.vim', cmd = 'Linediff', disable = true })

use({
  'Djancyp/cheat-sheet',
  config = function()
    require('cheat-sheet').setup({
      auto_fill = {
        current_word = false,
      },
      main_win = { border = 'single' },
      input_win = { border = 'single' },
    })
  end,
  disable = true,
})

use({
  'sindrets/diffview.nvim',
  event = 'BufReadPre',
  config = function()
    require('diffview').setup({
      default_args = {
        DiffviewFileHistory = { '%' },
      },
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
  disable = true,
})

use({
  'michaelb/sniprun',
  event = 'BufWinEnter',
  config = function()
    require('sniprun').setup({
      snipruncolors = {
        SniprunVirtualTextOk = {
          bg = 'Cyan',
          fg = 'Magenta',
          ctermbg = 'Cyan',
          cterfg = 'Black',
        },
        SniprunFloatingWinOk = { fg = P.darker_blue, ctermfg = 'Cyan' },
        SniprunVirtualTextErr = {
          bg = 'Cyan',
          fg = 'Magenta',
          ctermbg = 'DarkRed',
          cterfg = 'Cyan',
        },
        SniprunFloatingWinErr = { fg = P.error_red, ctermfg = 'DarkRed' },
      },
    })
  end,
  run = 'bash ./install.sh',
  disable = true,
})

use({
  'smjonas/inc-rename.nvim',
  config = function() require('inc_rename').setup({ hl_group = 'Visual' }) end,
  disable = true,
})

use({ 'diepm/vim-rest-console', disable = true })

use({
  'NTBBloodbath/rest.nvim',
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
  disable = true,
})

use({
  'wincent/command-t',
  run = 'cd lua/wincent/commandt/lib && make',
  cmd = { 'CommandT', 'CommandTRipgrep' },
  setup = function() vim.g.CommandTPreferredImplementation = 'lua' end,
  config = function() require('wincent.commandt').setup() end,
  disable = true,
})

use({
  'akinsho/toggleterm.nvim',
  disable = true,
  config = function()
    require('toggleterm').setup({
      open_mapping = [[<F2>]],
      shade_filetypes = { 'none' },
      shade_terminals = false,
      direction = 'float',
      persist_mode = true,
      insert_mappings = false,
      start_in_insert = true,
      autochdir = false,
      highlights = {
        NormalFloat = { link = 'NormalFloat' },
        FloatBorder = { link = 'FloatBorder' },
      },
      float_opts = {
        width = 150,
        height = 30,
        winblend = 3,
        border = rvim.style.border.current,
      },
      size = function(term)
        if term.direction == 'horizontal' then return 10 end
        if term.direction == 'vertical' then return math.floor(vim.o.columns * 0.3) end
      end,
    })
  end,
})

use({
  'linty-org/readline.nvim',
  disable = true,
  event = 'CmdlineEnter',
  config = function()
    local readline = require('readline')
    local map = vim.keymap.set
    map('!', '<M-f>', readline.forward_word)
    map('!', '<M-b>', readline.backward_word)
    map('!', '<C-a>', readline.beginning_of_line)
    map('!', '<C-e>', readline.end_of_line)
    map('!', '<M-d>', readline.kill_word)
    map('!', '<M-BS>', readline.backward_kill_word)
    map('!', '<C-w>', readline.unix_word_rubout)
    map('!', '<C-k>', readline.kill_line)
    map('!', '<C-u>', readline.backward_kill_line)
  end,
})

-- prevent select and visual mode from overwriting the clipboard
use({
  'kevinhwang91/nvim-hclipboard',
  disable = true,
  event = 'InsertCharPre',
  config = function() require('hclipboard').start() end,
})

use({
  'andrewferrier/debugprint.nvim',
  disable = true,
  config = function()
    local dp = require('debugprint')
    dp.setup({ create_keymaps = false })

    rvim.nnoremap(
      '<leader>dp',
      function() return dp.debugprint({ variable = true }) end,
      { desc = 'debugprint: cursor', expr = true }
    )
    rvim.nnoremap(
      '<leader>do',
      function() return dp.debugprint({ motion = true }) end,
      { desc = 'debugprint: operator', expr = true }
    )
    rvim.nnoremap('<leader>dC', '<Cmd>DeleteDebugPrints<CR>', 'debugprint: clear all')
  end,
})
