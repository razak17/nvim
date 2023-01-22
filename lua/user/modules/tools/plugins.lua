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
    'razak17/lab.nvim',
    event = { 'InsertEnter' },
    build = 'cd js && npm ci',
    config = function()
      require('lab').setup({
        runnerconf_path = join_paths(rvim.get_cache_dir(), 'lab', 'runnerconf'),
        code_runner = { enabled = false },
      })
    end,
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
    keys = {
      {
        '<leader>on',
        function() require('no-neck-pain').toggle() end,
        mode = 'n',
        desc = 'toggle no-neck-pain',
        noremap = true,
        silent = true,
        expr = false,
      },
    },
  },

  {
    'andrewferrier/debugprint.nvim',
    event = 'VeryLazy',
    init = function()
      rvim.nnoremap(
        '<leader>dp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        { desc = 'debugprint: cursor', expr = true }
      )
      rvim.nnoremap(
        '<leader>do',
        function() return require('debugprint').debugprint({ motion = true }) end,
        { desc = 'debugprint: operator', expr = true }
      )
      rvim.nnoremap('<leader>dx', '<Cmd>DeleteDebugPrints<CR>', 'debugprint: clear all')
    end,
    config = function()
      local dp = require('debugprint')
      dp.setup({ create_keymaps = false })
    end,
  },

  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    init = function()
      rvim.nnoremap('<leader>rs', '<Plug>RestNvim', 'rest: run')
      rvim.nnoremap('<leader>rp', '<Plug>RestNvimPreview', 'rest: preview')
      rvim.nnoremap('<leader>rl', '<Plug>RestNvimLast', 'rest: run last')
    end,
    config = function()
      require('rest-nvim').setup({
        -- Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = true,
      })
    end,
  },
}
