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
    'ahmedkhalf/project.nvim',
    event = 'VeryLazy',
    config = function()
      require('project_nvim').setup({
        detection_methods = { 'pattern', 'lsp' },
        ignore_lsp = { 'null-ls' },
        patterns = { '.git' },
        datapath = rvim.get_runtime_dir(),
      })
    end,
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
      })
      require('user.utils.highlights').plugin('harpoon', {
        theme = {
          ['zephyr'] = {
            { BufferManagerTitle = { fg = { from = 'Winbar' } } },
            { BufferManagerBorder = { fg = { from = 'FloatBorder' } } },
          },
        },
      })
    end,
  },

  {
    'numToStr/FTerm.nvim',
    event = 'VeryLazy',
    init = function()
      local function new_float(cmd)
        cmd =
          require('FTerm'):new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
      end
      rvim.nnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
      rvim.tnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
      rvim.nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
      rvim.nnoremap('<leader>ga', function() new_float('git add .') end, 'add all')
      rvim.nnoremap('<leader>gc', function() new_float('git commit -a -v') end, 'commit')
      rvim.nnoremap('<leader>gD', function() new_float('iconf -ccma') end, 'commit dotfiles')
      rvim.nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
      rvim.nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
      rvim.nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
      rvim.nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
    end,
    config = function()
      local fterm = require('FTerm')
      fterm.setup({ dimensions = { height = 0.8, width = 0.9 } })
    end,
  },

  {
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
        options = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help' },
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
        preview = {
          border_chars = { '│', '│', '─', '─', '┌', '┐', '└', '┘', '▊' },
        },
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
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    config = function()
      require('crates').setup({
        popup = {
          autofocus = true,
          style = 'minimal',
          border = rvim.style.current.border,
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
    keys = {
      {
        '<leader>dp',
        function() return require('debugprint').debugprint({ variable = true }) end,
        expr = true,
        desc = 'debugprint: cursor',
      },
      {
        '<leader>do',
        function() return require('debugprint').debugprint({ motion = true }) end,
        mode = 'o',
        expr = true,
        desc = 'debugprint: operator',
      },
      { '<leader>dx', '<Cmd>DeleteDebugPrints<CR>', desc = 'debugprint: clear all' },
    },
    config = function() require('debugprint').setup({ create_keymaps = false }) end,
  },

  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    init = function()
      rvim.nnoremap('<leader>rs', '<Plug>RestNvim', 'rest: run')
      rvim.nnoremap('<leader>rp', '<Plug>RestNvimPreview', 'rest: preview')
      rvim.nnoremap('<leader>rl', '<Plug>RestNvimLast', 'rest: run last')
    end,
    config = function() require('rest-nvim').setup({ skip_ssl_verification = true }) end,
  },
}
