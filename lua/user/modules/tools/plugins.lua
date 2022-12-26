local use = require('user.core.lazy').use
local conf = require('user.utils.plugins').load_conf

use({ 'nvim-lua/plenary.nvim' })

use({ 'nvim-lua/popup.nvim' })

use({ 'kkharji/sqlite.lua' })

use({
  'folke/which-key.nvim',
  lazy = false,
  config = conf('tools', 'which-key'),
})

use({
  'nvim-telescope/telescope.nvim',
  lazy = false,
  dependencies = {
    {
      'jvgrootveld/telescope-zoxide',
      config = function() require('telescope').load_extension('zoxide') end,
    },
    {
      'smartpde/telescope-recent-files',
      config = function() require('telescope').load_extension('recent_files') end,
    },
    {
      'nvim-telescope/telescope-media-files.nvim',
      config = function() require('telescope').load_extension('media_files') end,
    },
    {
      'nvim-telescope/telescope-dap.nvim',
      config = function() require('telescope').load_extension('dap') end,
    },
    {
      'natecraddock/telescope-zf-native.nvim',
      config = function() require('telescope').load_extension('zf-native') end,
    },
    {
      'nvim-telescope/telescope-ui-select.nvim',
      config = function() require('telescope').load_extension('ui-select') end,
    },
    {
      'benfowler/telescope-luasnip.nvim',
      config = function() require('telescope').load_extension('luasnip') end,
    },
    {
      'nvim-telescope/telescope-frecency.nvim',
      config = function() require('telescope').load_extension('frecency') end,
    },
    {
      'debugloop/telescope-undo.nvim',
      config = function() require('telescope').load_extension('undo') end,
    },
  },
  branch = 'master', -- '0.1.x',
  init = conf('tools', 'telescope').init,
  config = conf('tools', 'telescope').config,
})

use({
  'ThePrimeagen/harpoon',
  init = function()
    rvim.nnoremap('<leader>ma', function() require('harpoon.mark').add_file() end, 'harpoon: add')
    rvim.nnoremap('<leader>mn', function() require('harpoon.ui').nav_next() end, 'harpoon: next')
    rvim.nnoremap('<leader>mp', function() require('harpoon.ui').nav_prev() end, 'harpoon: prev')
    rvim.nnoremap(
      '<leader>m;',
      function() require('harpoon.ui').toggle_quick_menu() end,
      'harpoon: ui'
    )
    rvim.nnoremap(
      '<leader>mm',
      function()
        require('telescope').extensions.harpoon.marks(
          rvim.telescope.minimal_ui({ prompt_title = 'Harpoon Marks' })
        )
      end,
      'harpoon: marks'
    )
  end,
  config = function()
    require('harpoon').setup({
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
        borderchars = rvim.style.border.common,
      },
    })
    require('telescope').load_extension('harpoon')
  end,
})

use({
  'razak17/buffer_manager.nvim',
  init = function()
    rvim.nnoremap(
      '<tab>',
      function() require('buffer_manager.ui').toggle_quick_menu() end,
      'buffer_manager: toggle'
    )
  end,
  config = function()
    require('buffer_manager').setup({
      borderchars = rvim.style.border.common,
      border_highlight = 'VertSplit',
    })
  end,
})

use({
  'razak17/cybu.nvim',
  event = { 'BufRead', 'BufNewFile' },
  init = function()
    rvim.nnoremap('H', '<Plug>(CybuPrev)', 'cybu: prev')
    rvim.nnoremap('L', '<Plug>(CybuNext)', 'cybu: next')
  end,
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
  'gbprod/yanky.nvim',
  event = 'VeryLazy',
  init = conf('tools', 'yanky').init,
  config = conf('tools', 'yanky').config,
})

use({
  'ahmedkhalf/project.nvim',
  event = 'VeryLazy',
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
  event = 'VeryLazy',
  init = function()
    local function new_float(cmd)
      cmd = require('FTerm'):new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
    end
    rvim.nnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
    rvim.tnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
    rvim.nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
    rvim.nnoremap('<leader>ga', function() new_float('git add .') end, 'add all')
    rvim.nnoremap('<leader>gc', function() new_float('git commit -a -v') end, 'commit')
    rvim.nnoremap('<leader>gd', function() new_float('iconf -ccma') end, 'commit dotfiles')
    rvim.nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
    rvim.nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
    rvim.nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
    rvim.nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
  end,
  config = function()
    local fterm = require('FTerm')
    fterm.setup({ dimensions = { height = 0.8, width = 0.9 } })
  end,
})

use({
  'ggandor/leap.nvim',
  event = { 'BufRead', 'BufNewFile' },
  init = function()
    rvim.nnoremap('s', function()
      require('leap').leap({
        target_windows = vim.tbl_filter(
          function(win) return rvim.empty(vim.fn.win_gettype(win)) end,
          vim.api.nvim_tabpage_list_wins(0)
        ),
      })
    end, 'leap: search')
  end,
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
  end,
})

use({
  'ggandor/flit.nvim',
  keys = { 'n', 'f' },
  config = function()
    require('flit').setup({
      labeled_modes = 'nvo',
      multiline = false,
    })
  end,
})

use({
  'SmiteshP/nvim-navic',
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

use({
  'mbbill/undotree',
  event = 'VeryLazy',
  init = function() rvim.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle') end,
  config = function()
    vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_SplitWidth = 35
  end,
})

use({
  'iamcco/markdown-preview.nvim',
  build = function() vim.fn['mkdp#util#install']() end,
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
  event = 'VeryLazy',
  init = function() rvim.nnoremap('<leader>rr', ':silent only | Jaq<CR>', 'jaq: run') end,
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
  'folke/persistence.nvim',
  event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  init = function()
    rvim.nnoremap(
      '<leader>sr',
      '<cmd>lua require("persistence").load()<CR>',
      'persistence: restore for directory'
    )
    rvim.nnoremap(
      '<leader>sl',
      '<cmd>lua require("persistence").load({ last = true })<CR>',
      'persistence: restore last'
    )
  end,
  config = function()
    require('persistence').setup({
      dir = vim.fn.expand(rvim.get_cache_dir() .. '/sessions/'),
    })
  end,
})

use({
  'nvim-neotest/neotest',
  version = 'v2.*',
  event = { 'BufRead', 'BufNewFile' },
  init = function()
    local function neotest_open() require('neotest').output.open({ enter = true, short = false }) end
    local function run_file() require('neotest').run.run(vim.fn.expand('%')) end
    local function nearest() require('neotest').run.run() end
    local function next_failed() require('neotest').jump.prev({ status = 'failed' }) end
    local function prev_failed() require('neotest').jump.next({ status = 'failed' }) end
    local function toggle_summary() require('neotest').summary.toggle() end
    rvim.nnoremap('<localleader>ts', toggle_summary, 'neotest: run suite')
    rvim.nnoremap('<localleader>to', neotest_open, 'neotest: output')
    rvim.nnoremap('<localleader>tn', nearest, 'neotest: run')
    rvim.nnoremap('<localleader>tf', run_file, 'neotest: run file')
    rvim.nnoremap('[n', next_failed, 'jump to next failed test')
    rvim.nnoremap(']n', prev_failed, 'jump to previous failed test')
  end,
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
  dependencies = {
    'rcarriga/neotest-plenary',
    'rcarriga/neotest-vim-test',
    'nvim-neotest/neotest-python',
  },
})

use({
  'turbio/bracey.vim',
  ft = { 'html' },
  build = 'npm install --prefix server',
  init = function()
    rvim.nnoremap('<leader>bs', '<cmd>Bracey<CR>', 'bracey: start')
    rvim.nnoremap('<leader>be', '<cmd>BraceyStop<CR>', 'bracey: stop')
  end,
})

-- FIXME: handle insyallation freezes
-- use({
--   '0x100101/lab.nvim',
--   event = { 'InsertEnter' },
--   build = 'cd js && npm ci',
--   config = function() require('lab').setup() end,
-- })

use({
  'Saecki/crates.nvim',
  event = { 'BufRead Cargo.toml' },
  config = function()
    require('crates').setup({
      popup = {
        autofocus = true,
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
  end,
})

use({
  'razak17/package-info.nvim',
  event = { 'BufRead package.json' },
  dependencies = { 'MunifTanjim/nui.nvim' },
  config = function()
    require('package-info').setup({
      autostart = false,
      package_manager = 'yarn',
    })
  end,
})

use({
  'shortcuts/no-neck-pain.nvim',
  event = 'VeryLazy',
  init = function()
    rvim.nnoremap(
      '<leader>on',
      '<cmd>lua require("no-neck-pain").toggle()<CR>',
      'no-neck-pain: toggle'
    )
  end,
})

----------------------------------------------------------------------------------------------------
-- Graveyard
----------------------------------------------------------------------------------------------------
-- use({ 'AndrewRadev/linediff.vim', cmd = 'Linediff' })
--
-- use({
--   'Djancyp/cheat-sheet',
--   init = function() rvim.nnoremap('<localleader>s', '<cmd>CheatSH<CR>', 'cheat-sheet: search') end,
--   config = function()
--     require('cheat-sheet').setup({
--       auto_fill = {
--         current_word = false,
--       },
--       main_win = { border = 'single' },
--       input_win = { border = 'single' },
--     })
--   end,
-- })
--
-- use({
--   'sindrets/diffview.nvim',
--   event = { 'BufRead', 'BufNewFile' },
--   init = function()
--     rvim.nnoremap('<localleader>gd', '<cmd>DiffviewOpen<CR>', 'diffview: open')
--     rvim.nnoremap('<localleader>gh', '<Cmd>DiffviewFileHistory<CR>', 'diffview: file history')
--     rvim.vnoremap('gh', [[:'<'>DiffviewFileHistory<CR>]], 'diffview: file history')
--   end,
--   config = function()
--     require('diffview').setup({
--       default_args = {
--         DiffviewFileHistory = { '%' },
--       },
--       hooks = {
--         diff_buf_read = function()
--           vim.opt_local.wrap = false
--           vim.opt_local.list = false
--           vim.opt_local.colorcolumn = ''
--         end,
--       },
--       enhanced_diff_hl = true,
--       keymaps = {
--         view = { q = '<Cmd>DiffviewClose<CR>' },
--         file_panel = { q = '<Cmd>DiffviewClose<CR>' },
--         file_history_panel = { q = '<Cmd>DiffviewClose<CR>' },
--       },
--     })
--   end,
-- })
--
-- use({
--   'michaelb/sniprun',
--   event = 'BufWinEnter',
--   init = function()
--     rvim.nnoremap('<leader>sr', '<cmd>SnipRun<CR>', 'sniprun: run')
--     rvim.vnoremap('<leader>sr', '<cmd>SnipRun<CR>', 'sniprun: run')
--     rvim.nnoremap('<leader>sc', '<cmd>SnipClose<CR>', 'sniprun: close')
--     rvim.nnoremap('<leader>sx', '<cmd>SnipReset<CR>', 'sniprun: reset')
--   end,
--   config = function()
--     require('sniprun').setup({
--       snipruncolors = {
--         SniprunVirtualTextOk = {
--           bg = 'Cyan',
--           fg = 'Magenta',
--           ctermbg = 'Cyan',
--           cterfg = 'Black',
--         },
--         SniprunFloatingWinOk = { fg = P.darker_blue, ctermfg = 'Cyan' },
--         SniprunVirtualTextErr = {
--           bg = 'Cyan',
--           fg = 'Magenta',
--           ctermbg = 'DarkRed',
--           cterfg = 'Cyan',
--         },
--         SniprunFloatingWinErr = { fg = P.error_red, ctermfg = 'DarkRed' },
--       },
--     })
--   end,
--   run = 'bash ./install.sh',
-- })
--
-- use({
--   'smjonas/inc-rename.nvim',
--   init = function()
--     -- inc-rename.nvim
--     rvim.nnoremap(
--       '<leader>rn',
--       function() return ':IncRename ' .. vim.fn.expand('<cword>') end,
--       { expr = true, silent = false, desc = 'inc-rename: inc rename' }
--     )
--   end,
--   config = function() require('inc_rename').setup({ hl_group = 'Visual' }) end,
-- })
--
-- use({ 'diepm/vim-rest-console' })
--
-- use({
--   'NTBBloodbath/rest.nvim',
--   ft = { 'http', 'json' },
--   config = function()
--     require('rest-nvim').setup({
--       -- Open request results in a horizontal split
--       result_split_horizontal = true,
--       -- Skip SSL verification, useful for unknown certificates
--       skip_ssl_verification = true,
--       -- Jump to request line on run
--       jump_to_request = false,
--       custom_dynamic_variables = {},
--     })
--     rvim.nnoremap('<leader>rr', '<Plug>RestNvim', 'rest: run')
--     rvim.nnoremap('<leader>rp', '<Plug>RestNvimPreview', 'rest: run')
--     rvim.nnoremap('<leader>rl', '<Plug>RestNvimLast', 'rest: run')
--   end,
-- })
--
-- use({
--   'wincent/command-t',
--   run = 'cd lua/wincent/commandt/lib && make',
--   cmd = { 'CommandT', 'CommandTRipgrep' },
--   setup = function() vim.g.CommandTPreferredImplementation = 'lua' end,
--   config = function() require('wincent.commandt').setup() end,
-- })
--
-- use({
--   'akinsho/toggleterm.nvim',
--   init = function()
--     local new_term = function(direction, key, count)
--       local Terminal = require('toggleterm.terminal').Terminal
--       local fmt = string.format
--       local cmd = fmt('<cmd>%sToggleTerm direction=%s<CR>', count, direction)
--       return Terminal:new({
--         direction = direction,
--         on_open = function() vim.cmd('startinsert!') end,
--         rvim.nnoremap(key, cmd),
--         rvim.inoremap(key, cmd),
--         rvim.tnoremap(key, cmd),
--         count = count,
--       })
--     end
--     local float_term = new_term('float', '<f2>', 1)
--     local vertical_term = new_term('vertical', '<F3>', 2)
--     local horizontal_term = new_term('horizontal', '<F4>', 3)
--     rvim.nnoremap('<f2>', function() float_term:toggle() end)
--     rvim.inoremap('<f2>', function() float_term:toggle() end)
--     rvim.nnoremap('<F3>', function() vertical_term:toggle() end)
--     rvim.inoremap('<F3>', function() vertical_term:toggle() end)
--     rvim.nnoremap('<F4>', function() horizontal_term:toggle() end)
--     rvim.inoremap('<F4>', function() horizontal_term:toggle() end)
--   end,
--   config = function()
--     require('toggleterm').setup({
--       open_mapping = [[<F2>]],
--       shade_filetypes = { 'none' },
--       shade_terminals = false,
--       direction = 'float',
--       persist_mode = true,
--       insert_mappings = false,
--       start_in_insert = true,
--       autochdir = false,
--       highlights = {
--         NormalFloat = { link = 'NormalFloat' },
--         FloatBorder = { link = 'FloatBorder' },
--       },
--       float_opts = {
--         width = 150,
--         height = 30,
--         winblend = 3,
--         border = rvim.style.border.current,
--       },
--       size = function(term)
--         if term.direction == 'horizontal' then return 10 end
--         if term.direction == 'vertical' then return math.floor(vim.o.columns * 0.3) end
--       end,
--     })
--   end,
-- })
--
-- use({
--   'linty-org/readline.nvim',
--   event = 'CmdlineEnter',
--   config = function()
--     local readline = require('readline')
--     local map = vim.keymap.set
--     map('!', '<M-f>', readline.forward_word)
--     map('!', '<M-b>', readline.backward_word)
--     map('!', '<C-a>', readline.beginning_of_line)
--     map('!', '<C-e>', readline.end_of_line)
--     map('!', '<M-d>', readline.kill_word)
--     map('!', '<M-BS>', readline.backward_kill_word)
--     map('!', '<C-w>', readline.unix_word_rubout)
--     map('!', '<C-k>', readline.kill_line)
--     map('!', '<C-u>', readline.backward_kill_line)
--   end,
-- })
--
-- -- prevent select and visual mode from overwriting the clipboard
-- use({
--   'kevinhwang91/nvim-hclipboard',
--   event = 'InsertCharPre',
--   config = function() require('hclipboard').start() end,
-- })
--
-- use({
--   'andrewferrier/debugprint.nvim',
--   config = function()
--     local dp = require('debugprint')
--     dp.setup({ create_keymaps = false })
--
--     rvim.nnoremap(
--       '<leader>dp',
--       function() return dp.debugprint({ variable = true }) end,
--       { desc = 'debugprint: cursor', expr = true }
--     )
--     rvim.nnoremap(
--       '<leader>do',
--       function() return dp.debugprint({ motion = true }) end,
--       { desc = 'debugprint: operator', expr = true }
--     )
--     rvim.nnoremap('<leader>dC', '<Cmd>DeleteDebugPrints<CR>', 'debugprint: clear all')
--   end,
-- })
