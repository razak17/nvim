return {
  { 'nvim-lua/plenary.nvim' },
  { 'nvim-lua/popup.nvim' },
  { 'kkharji/sqlite.lua', event = 'VeryLazy' },

  {
    'AndrewRadev/linediff.vim',
    cmd = 'Linediff',
    init = function() rvim.nnoremap('<localleader>ll', '<cmd>Linediff<CR>', 'linediff: toggle') end,
  },

  {
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
  },

  {
    'ggandor/flit.nvim',
    keys = { 'n', 'f' },
    config = function()
      require('flit').setup({
        labeled_modes = 'nvo',
        multiline = false,
      })
    end,
  },

  {
    'mbbill/undotree',
    event = 'VeryLazy',
    init = function() rvim.nnoremap('<leader>u', '<cmd>UndotreeToggle<CR>', 'undotree: toggle') end,
    config = function()
      vim.g.undotree_TreeNodeShape = '◦' -- Alternative: '◉'
      vim.g.undotree_SetFocusWhenToggle = 1
      vim.g.undotree_SplitWidth = 35
    end,
  },

  {
    'iamcco/markdown-preview.nvim',
    build = function() vim.fn['mkdp#util#install']() end,
    ft = { 'markdown' },
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },

  {
    'kevinhwang91/nvim-bqf',
    ft = 'qf',
    config = function()
      require('bqf').setup({
        preview = { border_chars = rvim.style.border.bqf },
      })
    end,
  },

  {
    'turbio/bracey.vim',
    ft = { 'html' },
    build = 'npm install --prefix server',
    init = function()
      rvim.nnoremap('<leader>bs', '<cmd>Bracey<CR>', 'bracey: start')
      rvim.nnoremap('<leader>be', '<cmd>BraceyStop<CR>', 'bracey: stop')
    end,
  },

  {
    '0x100101/lab.nvim',
    event = { 'InsertEnter' },
    build = 'cd js && npm ci',
    config = function() require('lab').setup() end,
  },

  {
    'razak17/package-info.nvim',
    event = { 'BufRead package.json' },
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      require('package-info').setup({
        autostart = false,
        package_manager = 'yarn',
      })
    end,
  },

  {
    'shortcuts/no-neck-pain.nvim',
    event = 'VeryLazy',
    init = function()
      rvim.nnoremap(
        '<leader>on',
        '<cmd>lua require("no-neck-pain").toggle()<CR>',
        'no-neck-pain: toggle'
      )
    end,
  },

  ----------------------------------------------------------------------------------------------------
  -- Graveyard
  ----------------------------------------------------------------------------------------------------
  -- {
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
  -- },
  --
  -- {
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
  -- },
  --
  -- {
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
  -- },
  --
  -- {
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
  -- },
  --
  -- { 'diepm/vim-rest-console' },
  --
  -- {
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
  -- },
  --
  -- {
  --   'wincent/command-t',
  --   run = 'cd lua/wincent/commandt/lib && make',
  --   cmd = { 'CommandT', 'CommandTRipgrep' },
  --   setup = function() vim.g.CommandTPreferredImplementation = 'lua' end,
  --   config = function() require('wincent.commandt').setup() end,
  -- },
  --
  -- {
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
  -- },
  --
  -- {
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
  -- },
  --
  -- -- prevent select and visual mode from overwriting the clipboard
  -- {
  --   'kevinhwang91/nvim-hclipboard',
  --   event = 'InsertCharPre',
  --   config = function() require('hclipboard').start() end,
  -- },
  --
  -- {
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
  -- },
}
