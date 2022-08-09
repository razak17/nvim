local utils = require('user.utils.plugins')
local conf = utils.load_conf
local package = require('user.core.plugins').package

package({ 'Tastyep/structlog.nvim' })

package({ 'lewis6991/impatient.nvim' })

package({ 'folke/which-key.nvim', config = conf('tools', 'which_key') })

package({
  'mbbill/undotree',
  event = 'BufRead',
  config = function()
    vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_SplitWidth = 35
  end,
})

package({
  'ahmedkhalf/project.nvim',
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
  end,
})

package({
  'numToStr/FTerm.nvim',
  event = { 'BufWinEnter' },
  config = function()
    local fterm = require('FTerm')
    fterm.setup({ dimensions = { height = 0.9, width = 0.9 } })
  end,
})

package({
  'akinsho/toggleterm.nvim',
  config = function()
    require('toggleterm').setup({
      open_mapping = [[<F2>]],
      shade_filetypes = { 'none' },
      shade_terminals = false,
      direction = 'float',
      persist_mode = true,
      insert_mappings = false,
      start_in_insert = true,
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

package({
  'AckslD/nvim-neoclip.lua',
  event = { 'BufWinEnter' },
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
  end,
})

package({
  'nvim-telescope/telescope.nvim',
  branch = 'master', -- '0.1.x',
  config = conf('tools', 'telescope'),
  requires = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-lua/popup.nvim' },
    { 'jvgrootveld/telescope-zoxide' },
    { 'nvim-telescope/telescope-media-files.nvim' },
    { 'nvim-telescope/telescope-file-browser.nvim' },
    { 'nvim-telescope/telescope-dap.nvim' },
    { 'natecraddock/telescope-zf-native.nvim' },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'ilAYAli/scMRU.nvim' },
    { 'kkharji/sqlite.lua' },
    {
      'ThePrimeagen/harpoon',
      config = function()
        require('harpoon').setup({
          menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
            borderchars = rvim.style.border.telescope.prompt,
          },
        })
      end,
    },
  },
})

package({
  'rmagatti/auto-session',
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
  end,
})

package({
  'phaazon/hop.nvim',
  tag = 'v2.*',
  keys = { { 'n', 's' }, { 'n', 'f' }, { 'n', 'F' } },
  config = conf('tools', 'hop'),
})

package({ 'moll/vim-bbye', event = 'BufWinEnter' })

package({
  'SmiteshP/nvim-navic',
  requires = 'neovim/nvim-lspconfig',
  config = function()
    vim.g.navic_silence = true
    local highlights = require('user.utils.highlights')
    local s = rvim.style
    local misc = s.icons.misc
    highlights.set('NavicText', { bold = false })
    highlights.set('NavicSeparator', { link = 'Directory' })
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

package({
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  config = function()
    require('bqf').setup({
      preview = {
        border_chars = rvim.style.border.bqf,
      },
    })
  end,
})

package({ 'nvim-lua/plenary.nvim' })

package({
  'is0n/jaq-nvim',
  event = { 'BufWinEnter' },
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

package({
  'iamcco/markdown-preview.nvim',
  run = function() vim.fn['mkdp#util#install']() end,
  ft = { 'markdown' },
  config = function()
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
  disable = true,
})

package({
  'linty-org/readline.nvim',
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
package({
  'kevinhwang91/nvim-hclipboard',
  event = 'InsertCharPre',
  config = function() require('hclipboard').start() end,
})

package({ 'turbio/bracey.vim', run = 'npm install --prefix server' })

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
package({ 'AndrewRadev/linediff.vim', cmd = 'Linediff', disable = true })

package({
  'Djancyp/cheat-sheet',
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
  end,
  disable = true,
})

package({
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

package({
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

package({
  'vuki656/package-info.nvim',
  event = 'BufWinEnter',
  ft = { 'json' },
  config = function()
    require('package-info').setup({
      colors = {
        up_to_date = '#3C4048', -- Text color for up to date package virtual text
        outdated = '#d19a66', -- Text color for outdated package virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
        style = {
          up_to_date = '|  ', -- Icon for up to date packages
          outdated = '|  ', -- Icon for outdated packages
        },
      },
    })
    local package_info = require('package-info')
    local nnoremap = rvim.nnoremap
    nnoremap('<leader>ns', function() package_info.show() end, 'package-info: show')
    nnoremap('<leader>nc', function() package_info.hide() end, 'package-info: hide')
    nnoremap('<leader>nu', function() package_info.update() end, 'package-info: update')
    nnoremap('<leader>nd', function() package_info.delete() end, 'package-info: delete')
    nnoremap('<leader>ni', function() package_info.install() end, 'package-info: install')
    nnoremap('<leader>nr', function() package_info.reinstall() end, 'package-info: reinstall')
    nnoremap(
      '<leader>np',
      function() package_info.change_version() end,
      'package-info: change version'
    )
  end,
  requires = 'MunifTanjim/nui.nvim',
  disable = true,
})

package({
  'nvim-neotest/neotest',
  config = function()
    require('neotest').setup({
      diagnostic = {
        enabled = false,
      },
      icons = {
        running = rvim.style.icons.misc.clock,
      },
      floating = {
        border = rvim.style.border.current,
      },
      adapters = {
        require('neotest-plenary'),
      },
    })

    local function open() require('neotest').output.open({ enter = true, short = false }) end
    local function run_file() require('neotest').run.run(vim.fn.expand('%')) end
    local function nearest() require('neotest').run.run() end
    local function next_failed() require('neotest').jump.prev({ status = 'failed' }) end
    local function prev_failed() require('neotest').jump.next({ status = 'failed' }) end
    local function toggle_summary() require('neotest').summary.toggle() end
    rvim.nnoremap('<localleader>ts', toggle_summary, 'neotest: run suite')
    rvim.nnoremap('<localleader>to', open, 'neotest: output')
    rvim.nnoremap('<localleader>tn', nearest, 'neotest: run')
    rvim.nnoremap('<localleader>tf', run_file, 'neotest: run file')
    rvim.nnoremap('[n', next_failed, 'jump to next failed test')
    rvim.nnoremap(']n', prev_failed, 'jump to previous failed test')
  end,
  requires = {
    'rcarriga/neotest-plenary',
    'rcarriga/neotest-vim-test',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'antoinemadec/FixCursorHold.nvim',
  },
  disable = true,
})

package({
  'smjonas/inc-rename.nvim',
  config = function()
    require('inc_rename').setup({
      hl_group = 'Visual',
    })
  end,
  disable = true,
})

package({ 'diepm/vim-rest-console', disable = true })

package({
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
