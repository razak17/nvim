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
    if not rvim.plugin_installed('undotree') then return end
    vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_SplitWidth = 35
    rvim.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle')
  end,
})

package({
  'ahmedkhalf/project.nvim',
  config = function()
    if not rvim.plugin_installed('project.nvim') then return end
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
    if not rvim.plugin_installed('FTerm.nvim') then return end
    local fterm = require('FTerm')
    fterm.setup({ dimensions = { height = 0.9, width = 0.9 } })
    local function new_float(cmd)
      cmd = fterm:new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
    end
    local nnoremap = rvim.nnoremap
    nnoremap([[<c-\>]], function() fterm.toggle() end, 'fterm: toggle lazygit')
    rvim.tnoremap([[<c-\>]], function() fterm.toggle() end, 'fterm: toggle lazygit')
    nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
    nnoremap('<leader>gc', function() new_float('git add . && git commit -v -a') end, 'git: commit')
    nnoremap('<leader>gd', function() new_float('iconf -ccma') end, 'git: commit dotfiles')
    nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
    nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
    nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
    nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
  end,
})

package({
  'akinsho/toggleterm.nvim',
  event = { 'BufWinEnter' },
  config = conf('tools', 'toggleterm'),
})

package({
  'AckslD/nvim-neoclip.lua',
  config = function()
    if not rvim.plugin_installed('nvim-neoclip.lua') then return end
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
        if not rvim.plugin_installed('harpoon') then return end
        local ui = require('harpoon.ui')
        local m = require('harpoon.mark')
        require('harpoon').setup({
          menu = {
            width = vim.api.nvim_win_get_width(0) - 4,
            borderchars = rvim.style.border.telescope.prompt,
          },
        })
        require('which-key').register({
          ['<leader>mm'] = { m.add_file, 'harpoon: add' },
          ['<leader>m.'] = { ui.nav_next, 'harpoon: next' },
          ['<leader>m,'] = { ui.nav_prev, 'harpoon: prev' },
          ['<leader>m;'] = { ui.toggle_quick_menu, 'harpoon: ui' },
        })
      end,
    },
  },
})

package({
  'rmagatti/auto-session',
  config = function()
    if not rvim.plugin_installed('auto-session') then return end
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
})

package({
  'phaazon/hop.nvim',
  tag = 'v2.*',
  keys = { { 'n', 's' }, 'f', 'F' },
  config = conf('tools', 'hop'),
})

package({
  'moll/vim-bbye',
  event = 'BufWinEnter',
  config = function()
    if not rvim.plugin_installed('vim-bbye') then return end
    require('which-key').register({
      ['<leader>c'] = { ':Bdelete!<cr>', 'close buffer' },
      ['<leader>bx'] = { ':bufdo :Bdelete<cr>', 'close all' },
      ['<leader>q'] = { '<Cmd>Bwipeout<CR>', 'wipe buffer' },
    })
  end,
})

package({
  'SmiteshP/nvim-navic',
  requires = 'neovim/nvim-lspconfig',
  config = function()
    if not rvim.plugin_installed('nvim-navic') then return end
    vim.g.navic_silence = true
    local highlights = require('user.utils.highlights')
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
})

package({
  'kevinhwang91/nvim-bqf',
  ft = 'qf',
  config = function()
    if not rvim.plugin_installed('nvim-bqf') then return end
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
    if not rvim.plugin_installed('jaq-nvim') then return end
    require('jaq-nvim').setup({
      cmds = {
        default = 'term',
        external = {
          typescript = 'deno run %',
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
    rvim.nnoremap('<leader>rr', ':silent only | Jaq<cr>', 'jaq: run')
  end,
})

package({
  'iamcco/markdown-preview.nvim',
  run = function() vim.fn['mkdp#util#install']() end,
  ft = { 'markdown' },
  config = function()
    if not rvim.plugin_installed('markdown-preview.nvim') then return end
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_auto_close = 1
  end,
  disable = true,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
package({ 'AndrewRadev/linediff.vim', cmd = 'Linediff', disable = true })

package({ 'diepm/vim-rest-console', disable = true })

package({
  'NTBBloodbath/rest.nvim',
  requires = { 'nvim-lua/plenary.nvim' },
  ft = { 'http', 'json' },
  config = function()
    if not rvim.plugin_installed('rest.nvim') then return end
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

package({
  'sindrets/diffview.nvim',
  event = 'BufReadPre',
  setup = function()
    if not rvim.plugin_installed('diffview.nvim') then return end
    rvim.nnoremap('<localleader>gd', '<Cmd>DiffviewOpen<CR>', 'diffview: open')
    rvim.nnoremap('<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', 'diffview: file history')
    rvim.vnoremap('gh', [[:'<'>DiffviewFileHistory<CR>]], 'diffview: file history')
  end,
  config = function()
    if not rvim.plugin_installed('diffview.nvim') then return end
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
    if not rvim.plugin_installed('sniprun') then return end
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

    rvim.nnoremap('<leader>sr', ':SnipRun<cr>', 'sniprun: run')
    rvim.vnoremap('<leader>sr', ':SnipRun<cr>', 'sniprun: run')
    rvim.nnoremap('<leader>sc', ':SnipClose<cr>', 'sniprun: close')
    rvim.nnoremap('<leader>sx', ':SnipReset<cr>', 'sniprun: reset')
  end,
  run = 'bash ./install.sh',
  disable = true,
})

package({
  'vuki656/package-info.nvim',
  event = 'BufWinEnter',
  ft = { 'json' },
  config = function()
    if not rvim.plugin_installed('package-info.nvim') then return end
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
    if not rvim.plugin_installed('neotest') then return end
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
    if not rvim.plugin_installed('inc-rename.nvim') then return end
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
  disable = true,
})

package({
  'Djancyp/cheat-sheet',
  config = function()
    if not rvim.plugin_installed('cheat-sheet') then return end
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
  disable = true,
})
